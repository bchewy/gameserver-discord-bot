import os
from dotenv import load_dotenv
import discord
from discord.ext import commands

load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")
# print(BOT_TOKEN)

intents = discord.Intents.default()
intents.messages = True
intents.guilds = True
intents.message_content = True

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print(f"We have logged in as {bot.user}")

@bot.command()
async def hello(ctx):
    await ctx.send("Hello there!")

# Run the bot.
bot.activity = discord.Game(name="with the API")
bot.run(BOT_TOKEN)
