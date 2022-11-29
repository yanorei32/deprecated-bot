use once_cell::sync::OnceCell;
use serenity::async_trait;
use serenity::model::channel::Message;
use serenity::prelude::*;

mod model;
static CONFIG: OnceCell<model::Config> = OnceCell::new();

#[tokio::main]
async fn main() {
    CONFIG
        .set(envy::from_env::<model::Config>().expect("Failed to get environment"))
        .unwrap();

    let c = CONFIG.get().unwrap();

    let intents = GatewayIntents::non_privileged() | GatewayIntents::MESSAGE_CONTENT;
    let mut client = Client::builder(&c.token, intents)
        .event_handler(Handler)
        .await
        .expect("Error creating client");

    if let Err(why) = client.start().await {
        eprintln!("An error occurred while running the client: {:?}", why);
    }
}

struct Handler;

#[async_trait]
impl EventHandler for Handler {
    async fn message(&self, ctx: Context, msg: Message) {
        let c = CONFIG.get().unwrap();

        // if trigger is not match
        if msg.content != c.trigger {
            return;
        }

        match msg
            .channel(&ctx)
            .await
            .expect("Failed to fetch channel")
            .guild()
        {
            Some(guild) => {
                // if bot is already joined
                if guild
                    .members(&ctx)
                    .await
                    .expect("Failed to fetch channel")
                    .iter()
                    .any(|v| v.user.id == c.target)
                {
                    return;
                }

                msg.reply(
                    &ctx,
                    format!(
                        "This bot is deprecated.\n\
                            Please enable a new bot instance:\n\
                            https://discord.com/oauth2/authorize?client_id={}&scope=bot",
                        c.target
                    ),
                )
                .await
                .expect("Failed to send a message");
            }
            None => return,
        }
    }
}
