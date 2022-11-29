use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct Config {
    pub target: u64,
    pub trigger: String,
    pub token: String,
}
