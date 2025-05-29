# pylint: disable=line-too-long, too-many-arguments
"""
Most of the log function will placed here.
If a log function required a specific package it will be putted in that package utils.
Es. httpx logger will be put in the httpx utils.
"""

import logging
from logging import Logger
from typing import Dict


def log_constructor(
    *,
    log: Logger,
    self: object,
    baseurl: str,
    user_agent: str,
    session_cookie: str,
    config: Dict,
) -> None:
    """
    Construct a log message for the constructor of an object.

    :param log: the logger object to use for the log message
    :param self: the object being created
    :param baseurl: the baseurl to log
    :param user_agent: the user_agent to log
    :param session_cookie: the session cookie to log
    :param config: the configuration to log
    :return: None
    """
    if log.isEnabledFor(logging.DEBUG):
        log.debug(
            f"Create object {self.__class__.__name__} with baseurl {baseurl}, agent {user_agent}, session_cookie {session_cookie} and config {config}"  # noqa E501
        )


def log_interaction(log: Logger, i: int) -> None:
    """
    Construct a log message for log that print the current interaction

    :param log: the logger object to use for the log message
    :param i: the number of the interaction
    :return: None
    """
    if log.isEnabledFor(logging.DEBUG):
        log.debug(f"Interaction {i}")


def log_sleep(log: Logger, time: int) -> None:
    """
    Log a message indicating the duration of sleep.

    :param log: the logger object to use for the log message
    :param time: the duration of sleep in seconds
    :return: None
    """

    if log.isEnabledFor(logging.DEBUG):
        log.debug(f"Sleeping for {time} seconds")


def configure_logger(
    name: str = "vinted_scraper",
    level: int = logging.INFO,
    fmt: str = "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt: str = "%Y-%m-%d %H:%M:%S",
    stream: object = None,
) -> Logger:
    """
    Configure and return a logger for the package.

    :param name: Logger name (default: 'vinted_scraper')
    :param level: Logging level (default: logging.INFO)
    :param fmt: Log message format
    :param datefmt: Date format for log messages
    :param stream: Stream for logging output (default: sys.stderr)
    :return: Configured logger
    """
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler(stream)
        formatter = logging.Formatter(fmt=fmt, datefmt=datefmt)
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    logger.setLevel(level)
    return logger
