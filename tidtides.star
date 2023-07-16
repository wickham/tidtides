# pixlet serve C:\Users\mynam\Documents\Code\tidtides\tidtides.star
load("render.star", "render")
load("time.star", "time")
load("math.star", "math")
load("encoding/base64.star", "base64")
load("schema.star", "schema")
load("encoding/json.star", "json")

# number of items to render
NUM_ITEMS = 1

# display defaults and colors
C_DISPLAY_WIDTH = 64
C_ANIMATION_DELAY = 32
C_BACKGROUND = [0, 0, 0]
C_TEXT_COLOR = [255, 255, 255]

# number of animation frames
C_ANIMATION_FRAMES = 60
C_ITEM_FRAMES = 15
C_END_FRAMES = 15

# configuration for infinite (no progress information) animation
C_INFINITE_PROGRESS_PAD_FRAMES = 50
C_INFINITE_PROGRESS_PAD_SCALE = 10.0
C_INFINITE_PROGRESS_PAD_PIXELS = int(
    C_INFINITE_PROGRESS_PAD_FRAMES / C_INFINITE_PROGRESS_PAD_SCALE
)
C_INFINITE_PROGRESS_FRAMES = C_INFINITE_PROGRESS_PAD_FRAMES * 2 - 2

C_MIN_WIDTH = 2
C_HEIGHT = 8
C_PADDING = 0


# Helltides Image
BTC_ICON = base64.decode(
    """
iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAA
AAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAA
AACshmLzAAACcklEQVRYCbVXSy8EQRDu3R3iTUT2KG4b4hEkLEFcXVz8AomjhJ/g6OLgKFzdxEHcJYg4
eGWJJfHYeMRBQrCJdRpdbWumu6enp2fWTtJb3VVffV9Nv4YYif7YUmpMGhsN40YoL4iJZ4ZHCLRSnigF
OOIoXCwC/En0ldPaVJA1KgKiQj+scJR1q6MiX/zUz2Yvye77G2iH5ouyBHlQ6j7YB8OeqOKQHKWAP9V/
+g1bwOg/6To0YdbMbq2qJg+Fb5a83J5ySKAzl70WxnRgxG06A/bB4BDZ7utnIrI4KsPG5Dcn+nXWpErP
udcRYqy4SQP5LUwwtVNnp2QymSRLuXshpdGyyN5Amvn4EyKAShywS4dyqC4fIUYxa6ZaQXsAiYEPphMb
41/p6GS2+IMxsDO0YS5Y3yeoAExUkqVqa0ll3JQCqUSry7b53b7e3SNm0lFzRQU5Sg97/OgwORG6AshY
Uwtyka66euz/nUUclWi1BSRisJzuU3yjI9cj9Phlgi+kEPQbaAvYeX91Lpbpi3PGoSOWYxMnfrW65WgL
ePn5cUSPPz/cLEVPFgfIc6GgQIouvwLY0Vm8y4nokCOuKFweD4NfAR5guRyqAtgG4qo30tZdvxxXm0ym
KkDGsDFHooyjE3Ay9jKfR9894tCG/hhhoqk9pJ/xmkTCF66dAflNgEU31SoVSXxTxoSagSBxPi4XD8tA
nw25ANUMxHgi6GOjyeO0idejy8h/DccgZ/4q60QXbm+gn3EcAR08t+w+UGBZnL4l/0+JAub528GDUc0A
D/J7Wx6j67P81adHHSZyzN7q7bcbLAtnS0dkgtHl+8ZKJv4FVajBa+2xvwcAAAAASUVORK5CYII=
"""
)
# last_helltide_started = time.time(
#     hour=5, minute=30, month=7, day=10, year=2023
# ).in_location("America/Los_Angeles")
first_helltide_started = time.time(
    hour=7, minute=0, month=7, day=10, year=2023
).in_location("America/Los_Angeles")


def get_helltide_info(last_helltide=first_helltide_started):
    now = time.now().in_location("America/Los_Angeles")
    helltide_dict = {}
    active_helltide = False
    time_remains = "0s"
    chest_resets = None
    chest_reset_seconds = "0s"
    next_helltide_from_start = "2h15m"

    while int(time.parse_duration(now - last_helltide).minutes) >= 135:
        last_helltide = last_helltide + time.parse_duration(next_helltide_from_start)
        if now >= last_helltide and now <= (last_helltide + time.parse_duration("1h")):
            # print("ENDS: ", last_helltide + time.parse_duration("1h"))
            if last_helltide.minute != 0:
                chest_resets = last_helltide + time.parse_duration(
                    str(60 - (last_helltide.minute)) + "m"
                )
            if (
                chest_resets != None
                and int(time.parse_duration((chest_resets - now)).seconds) > 0
            ):
                chest_reset_seconds = (
                    str(time.parse_duration((chest_resets - now)).seconds) + "s"
                )
            time_remains = (
                str(3600 - float(time.parse_duration((now - last_helltide)).seconds))
                + "s"
            )
            active_helltide = True

    helltide_dict["active_helltide"] = active_helltide
    helltide_dict["time_remaining"] = time_remains
    helltide_dict["last_helltide"] = last_helltide
    helltide_dict["next_helltide"] = last_helltide + time.parse_duration("2h15m")
    helltide_dict["chest_resets"] = chest_resets
    helltide_dict["chest_reset_seconds"] = chest_reset_seconds or "0s"
    print(helltide_dict)
    return helltide_dict


def get_last_helltide():
    return get_helltide_info().get("last_helltide")


def is_helltide_active():
    return get_helltide_info().get("active_helltide")


def get_next_helltide():
    return get_helltide_info().get("next_helltide")


def time_color():
    if (
        int(time.parse_duration(get_helltide_info().get("time_remaining")).seconds)
        <= 300
    ):
        return "#F00"
    else:
        return "#FFF"


def progress_bar(start, end, style="#0F0"):
    return


helltide_active = False


def formatted_helltide_duration():
    print(int(time.parse_duration(get_helltide_info().get("time_remaining")).seconds))
    if int(time.parse_duration(get_helltide_info().get("time_remaining")).seconds) < 60:
        text = "0m {}s".format(
            str(
                time.parse_duration(get_helltide_info().get("time_remaining")).seconds
            ).split(".", 1)[0]
        )
        rendered = render.Animation(
            children=[
                render.Text(content=text, font="6x13", color="#F00"),
                render.Text(content=text, font="6x13", color="#A00"),
            ],
        )
    elif time.parse_duration(get_helltide_info().get("time_remaining")).seconds <= 300:
        text = "{}m {}s".format(
            (
                (
                    str(
                        time.parse_duration(get_helltide_info().get("time_remaining"))
                    ).split("m", 1)[0]
                )
            )
            or "0",
            str(time.parse_duration(get_helltide_info().get("time_remaining")))
            .split("m")[-1]
            .split(".", 1)[0],
        )
        rendered = render.Animation(
            children=[
                render.Text(content=text, font="6x13", color="#F00"),
                render.Text(content=text, font="6x13", color="#000"),
            ],
        )
    else:
        text = "{}m {}s".format(
            (
                (
                    str(
                        time.parse_duration(get_helltide_info().get("time_remaining"))
                    ).split("m", 1)[0]
                )
            )
            or "0",
            str(time.parse_duration(get_helltide_info().get("time_remaining")))
            .split("m")[-1]
            .split(".", 1)[0],
        )
        rendered = render.Animation(
            children=[
                render.Text(content=text, font="6x13", color=time_color()),
                render.Text(content=text, font="6x13", color=time_color()),
            ],
        )
    return rendered


next = render.Root(
    delay=500,
    max_age=120,
    child=render.Box(
        color="#000",
        child=render.Row(
            expanded=True,
            # main_align="space_between",
            cross_align="top",
            children=[
                render.Image(
                    src=BTC_ICON,
                    width=15,
                    height=15,
                ),
                render.Column(
                    cross_align="center",
                    children=[
                        render.WrappedText(
                            width=36,
                            content="Next HellTide",
                            align="center",
                            font="tb-8",
                        ),
                        render.Animation(
                            children=[
                                render.Text(
                                    content=get_next_helltide().format("3:04 PM"),
                                    font="6x13",
                                ),
                                render.Text(
                                    content=get_next_helltide().format("3 04 PM"),
                                    font="6x13",
                                ),
                            ],
                        ),
                        render.Plot(
                            data=[
                                (0, 1),
                                (1, 1),
                                (2, 1),
                                (3, 1),
                                (4, 1),
                                (5, 1),
                                (6, 1),
                                (7, 1),
                                (8, 1),
                                (9, 1),
                            ],
                            width=64,
                            height=2,
                            color="#0f0",
                            color_inverted="#f00",
                            x_lim=(0, 50),
                            y_lim=(0, 1),
                            fill=True,
                        ),
                    ],
                ),
            ],
        ),
    ),
)

now = render.Root(
    delay=500,
    max_age=120,
    child=render.Box(
        color="#300",
        child=render.Row(
            expanded=True,
            # main_align="space_between",
            cross_align="top",
            children=[
                render.Image(
                    src=BTC_ICON,
                    width=15,
                    height=15,
                ),
                render.Column(
                    cross_align="center",
                    children=[
                        render.WrappedText(
                            width=36,
                            content="HellTide Active!",
                            align="center",
                            color="#F00",
                            font="tb-8",
                        ),
                        formatted_helltide_duration(),
                        render.Plot(
                            data=[
                                (0, 1),
                                (1, 1),
                                (2, 1),
                                (3, 1),
                                (4, 1),
                                (5, 1),
                                (6, 1),
                                (7, 1),
                                (8, 1),
                                (9, 0),
                            ],
                            width=64,
                            height=2,
                            color="#0f0",
                            color_inverted="#f00",
                            x_lim=(0, 9),
                            y_lim=(0, 1),
                            fill=True,
                        ),
                    ],
                ),
            ],
        ),
    ),
)


def main(config):
    print("\n\n\n\n[----- CONNECT TO PREVIEW AT http://localhost:8080/ -----]\n\n")
    print("---------------------------------------")
    print(json.decode(config.get("location")).get("timezone"))
    print(config.get("toggle1"))
    print("---------------------------------------")
    if is_helltide_active():
        return now
    else:
        return next


def get_progress_items(config):
    items = []
    for i in range(1, NUM_ITEMS + 1):
        label = config.get("label%d" % (i))
        color = config.get("color%d" % (i))
        progress = config.get("progress%d" % (i))
        if label != None and label != "":
            if color == None:
                color = ""
            if progress != None and progress != "":
                progress = float(progress)
                if progress < 0.0:
                    progress = 0.0
                elif progress > 100.0:
                    progress = 100.0
            else:
                progress = None
            items.append([label, color, progress])

        # show up to 4 items, regardless of how many were configured
        if len(items) >= 4:
            break
    return items


def get_schema():
    fields = []
    for i in range(1, NUM_ITEMS + 1):
        fields += [
            schema.Toggle(
                id="toggle%d" % (i),
                name="Toggle %d" % (i),
                desc="Label for item %d" % (i),
                icon="gear",
                default=False,
            ),
            schema.Location(
                id="location",
                name="Location",
                desc="Location for which to display time.",
                icon="locationDot",
            ),
            schema.Text(
                id="progress%d" % (i),
                name="Progress %d" % (i),
                desc="Progress for item %d" % (i),
                icon="gear",
                default="",
            ),
            schema.Color(
                id="color%d" % (i),
                name="Color %d" % (i),
                desc="Color for item %d" % (i),
                icon="brush",
                default="#ccc",
                palette=[
                    "#7AB0FF",
                    "#BFEDC4",
                    "#78DECC",
                    "#DBB5FF",
                ],
            ),
        ]
    return schema.Schema(
        version="1",
        fields=fields,
    )
