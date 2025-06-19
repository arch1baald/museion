import logging

import typer
from typing_extensions import Annotated

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)  # TODO: logging config

app = typer.Typer(
    pretty_exceptions_enable=True,
    pretty_exceptions_show_locals=False,
)


@app.callback()
def set_log_level(
    verbose: Annotated[int, typer.Option("--verbose", "-v", count=True)] = 0,
    quiet: Annotated[int, typer.Option("--quiet", "-q", count=True)] = 0,
) -> None:
    level = logging.INFO
    if verbose > 0:
        level = logging.DEBUG
    elif quiet > 2:
        level = logging.CRITICAL
    elif quiet > 1:
        level = logging.ERROR
    elif quiet > 0:
        level = logging.WARN

    root = logging.getLogger()
    root.setLevel(level)


@app.command(name="echo", help="Echo a message")
def app_echo(text: str = "Hello, World!") -> None:
    logger.info("Echoing message: %s", text)
    typer.echo(text)


@app.command(name="print-root", help="Print the root directory")
def app_print_root() -> None:
    from museion.constants import ROOT

    print(ROOT)


if __name__ == "__main__":
    app()
