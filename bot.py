import os
from dotenv import load_dotenv
# import discord
# from discord.ext import commands
from interactions import *
from interactions.api.events import Component
from asyncio import TimeoutError

load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")

bot = Client(intents=Intents.DEFAULT)
@listen()  # this decorator tells snek that it needs to listen for the corresponding event, and run this coroutine
async def on_ready():
    # This event is called when the bot is ready to respond to commands
    print("Ready")
    print(f"This bot is owned by {bot.owner}")

@listen()
async def on_message_create(event):
    # This event is called when a message is sent in a channel the bot can see
    print(f"message received: {event.message.content}")
    print(event)
    print(event.message)
    print(event.message.content)

@slash_command(name="help", description="Help menu WIP")
async def my_command_function(ctx: SlashContext):
    await ctx.send("Work in Progress")






@slash_command(name="deploy_server", description="lorem")
async def deploy_server(ctx: SlashContext):
    components: list[ActionRow] = [
        ActionRow(
            Button(
                custom_id="start_server",
                style=ButtonStyle.GREEN,
                label="Start Server",
            ),
            Button(
                custom_id="stop_server",
                style=ButtonStyle.GREEN,
                label="Shut Down Server",
            )
        )
    ]
    await ctx.send("Deploy your squad server now.", components=components)


@listen()
async def on_component(event: Component):
    ctx = event.ctx

    match ctx.custom_id:
        case "start_server":
            await ctx.send("You clicked it!")
    match ctx.custom_id:
        case "stop_server":
            await ctx.send("You clicked it!")

bot.start(BOT_TOKEN)


# ARCHIVE

# Context Menu Examples
# https://interactions-py.github.io/interactions.py/Guides/04%20Context%20Menus/
# @message_context_menu(name="repeat")
# async def repeat(ctx: ContextMenuContext):
#     message: Message = ctx.target
#     await ctx.send(message.content)

# @user_context_menu(name="ping")
# async def ping(ctx: ContextMenuContext):
#     member: Member = ctx.target
#     await ctx.send(member.mention)








# OLD CODE

# intents = discord.Intents.default()
# intents.messages = True
# intents.guilds = True
# intents.message_content = True

# bot = commands.Bot(command_prefix='!', intents=intents)
# slash = SlashCommand(bot, sync_commands=True)  # Initializes the slash command system

# @bot.event
# async def on_ready():
#     print(f"We have logged in as {bot.user}")

# @slash.slash(name="hello", description="Say hello to the bot!")  # Define the slash command
# async def _hello(ctx: SlashContext):
#     await ctx.send(content="Hello there!")

# bot.activity = discord.Game(name="with the API")
# bot.run(BOT_TOKEN)
