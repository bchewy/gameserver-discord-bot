import os
from dotenv import load_dotenv
# import discord
# from discord.ext import commands
from interactions import Client, Intents, listen, slash_command, SlashContext

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

@slash_command(name="my_command", description="My first command :)")
async def my_command_function(ctx: SlashContext):
    await ctx.send("Hello World")

bot.start(BOT_TOKEN)

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
