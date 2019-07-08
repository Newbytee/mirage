# Copyright 2019 miruka
# This file is part of harmonyqml, licensed under LGPLv3.

from typing import Any

from dataclasses import dataclass, field

from .event import Event


@dataclass
class ExitRequested(Event):
    exit_code: int = 0


@dataclass
class CoroutineDone(Event):
    uuid:   str = field()
    result: Any = None
