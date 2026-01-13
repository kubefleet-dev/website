# Record an asciinema demo for Fleet

This document explains how to record an asciinema demo for Fleet, which is featured
on the Fleet documentation site's main page to showcase the major functionalities
and the DX/UX of Fleet with terminal-based animation.

## Before you begin

Note: the recording should be done in a Unix-like environment (Linux, macOS, or WSL).

* Install Python 3 (>=3.7) on your local machine.
* Enable the Python virtual environment in this directory and install the dependencies.

    ```sh
    python3 -m venv ./venv
    source ./venv/bin/activate
    pip3 install -r requirements.txt
    ```

    It may take a few seconds before the commands are completed.

* Install asciinema.

    If you have [Homebrew](brew.sh) installed on your local machine, run the command below
    to install asciinema as a brew formula.

    ```sh
    brew install asciinema
    ```

    The installation may take a few seconds to complete. For other installation methods,
    refer to the [asciinema documentation](https://docs.asciinema.org/getting-started).

## Get recording started

Run the `record.sh` script to start recording:

```sh
chmod +x ./record.sh
./record.sh
```

It will take some time to complete the recording. To avoid interruptions, do not type
any word when the recording is in session.

## Add the cast

After the recording completes, a file named `demo.cast` will appear in the local directory.
Move the file under the `assets/asciinema` folder to add the cast. For the new cast to take effect,
re-generate the site and upload the resources.
