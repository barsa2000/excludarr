import typer
from typing import Optional
from loguru import logger

from excludarr.commands import MyContext
from excludarr.modules.justwatch import justwatch
from excludarr.utils.config import Config
from excludarr.utils import output

app = typer.Typer()


@app.command(help="Get all the possible providers for your locale")
def list(
    ctx: typer.Context,
    locale: Optional[str] = typer.Option(
        None, "-l", "--locale", metavar="LOCALE", help="Your locale e.g: en_US."
    ),
):
    config: Config = ctx.obj.config
    # Check if locale is set on CLI otherwise get the value from the config
    if not locale:
        locale = config.locale

    justwatch_client = justwatch.JustWatch(locale)
    jw_providers = justwatch_client.get_providers()

    output.print_providers(jw_providers)


@app.callback()
def init(ctx: typer.Context):
    """
    Initializes the command. Reads the configuration.
    """
    logger.debug("Got radarr as subcommand")

    # Hacky way to get the current log level context
    loglevel = logger._core.min_level  # type: ignore

    logger.debug("Reading configuration file")
    config = Config()

    ctx.obj = MyContext()

    ctx.obj.config = config
    ctx.obj.loglevel = loglevel
