import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import gen_backend  # noqa: E402

CONFIG = {
    "state": {"bucket": "acme-state", "region": "eu-west-1", "kms_alias": "alias/acme"},
    "environments": {
        "dev": {"root": "live/workload"},
        "prod": {"root": "live/workload"},
        "management": {"root": "live/management"},
    },
}


def test_render_uses_environment_name_as_state_key():
    text = gen_backend.render("dev", CONFIG["state"])
    assert 'key          = "dev/terraform.tfstate"' in text
    assert 'kms_key_id   = "alias/acme"' in text
    assert "use_lockfile = true" in text
    assert "dynamodb_table" not in text
    assert text.startswith("# Generated")


def test_environments_never_share_a_state_key():
    keys = {gen_backend.render(name, CONFIG["state"]).split("key ")[1].split("\n")[0]
            for name in CONFIG["environments"]}
    assert len(keys) == len(CONFIG["environments"])


def test_generate_writes_one_file_per_environment(tmp_path):
    gen_backend.generate(CONFIG, tmp_path)
    assert (tmp_path / "live/workload/backend/dev.hcl").exists()
    assert (tmp_path / "live/workload/backend/prod.hcl").exists()
    assert (tmp_path / "live/management/backend/management.hcl").exists()


def test_check_mode_reports_missing_and_stale_files(tmp_path):
    assert len(gen_backend.generate(CONFIG, tmp_path, check=True)) == 3
    gen_backend.generate(CONFIG, tmp_path)
    assert gen_backend.generate(CONFIG, tmp_path, check=True) == []
    (tmp_path / "live/workload/backend/dev.hcl").write_text("bucket = \"somewhere-else\"\n")
    assert gen_backend.generate(CONFIG, tmp_path, check=True) == ["live/workload/backend/dev.hcl"]


def test_unknown_environment_is_rejected(tmp_path):
    with pytest.raises(gen_backend.ConfigError):
        gen_backend.generate(CONFIG, tmp_path, only="staging")


@pytest.mark.parametrize("body", [
    "environments: {dev: {root: live/x}}",                                  # no state block
    "state: {bucket: b, region: r}",                         # no environments
    "state: {bucket: b, region: r}\nenvironments: {Dev!: {root: x}}",
    "state: {bucket: b, region: r}\nenvironments: {dev: {}}",
])
def test_invalid_config_is_rejected(tmp_path, body):
    path = tmp_path / "environments.yaml"
    path.write_text(body)
    with pytest.raises(gen_backend.ConfigError):
        gen_backend.load_config(path)


def test_repo_config_is_valid():
    config = gen_backend.load_config(gen_backend.REPO_ROOT / "environments.yaml")
    assert {"management", "dev", "prod"} <= set(config["environments"])
