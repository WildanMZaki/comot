# Comot - A Simple File Management CLI

Comot is a simple and playful CLI tool for moving or copying files from the default Downloads directory (or another source) to a target directory. It provides flexibility with wildcard patterns and filtering options for file types like images, videos, and more. 

## Features
- Move or copy files from the Downloads directory to the target directory.
- Supports wildcard patterns for handling multiple files.
- File type filtering for images, videos, audio, and custom extensions.
- User-defined alias for easy access.
- Flags can be placed anywhere in the command, offering great flexibility.

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/WildanMZaki/comot
cd comot
```

### Step 2: Run the Installation Script

```bash
./install.sh
```

During the installation, you will be prompted to choose a preferred alias (default: `comot`). This alias will be used to invoke the tool.

Example:
```bash
Enter your preferred command alias (comot): 
```

### Step 3: Update Terminal

Once the installation completes, either restart your terminal or run:
```bash
source ~/.bashrc
```

This step ensures your alias is properly loaded.

## Usage

You can use the **Comot** CLI tool with the alias you chose during installation. The tool provides several options for moving or copying files.

### Basic Usage
```bash
comot <filename> [target directory]
```
- `filename`: The name of the file to move/copy.
- `target directory`: (Optional) The directory where the file will be moved or copied. If not provided, it defaults to the current directory.

Example:
```bash
comot myimage.png path/to/target
```

### Filename Selection Feature

If you provide a partial filename or forget the exact name, **Comot** will help you by searching for matching files in the Downloads directory. The tool will display a list of matching files, allowing you to choose the correct one.

#### Example:
```bash
comot cat
```
If you run the above command and there are multiple files starting with "cat", Comot will display a selection like this:
```bash
Select the file you want (1-3):
1) cat1.png
2) cat2.jpg
3) cat_video.mp4
```
You can select the file by entering the corresponding number.

### Copying Files
To copy instead of move, use the `-c` flag:
```bash
comot -c <filename> [target directory]
```

Example:
```bash
comot -c myimage.png path/to/target
```

### Wildcard Patterns

You can use wildcard patterns (`*`) to handle multiple files.

Example:
```bash
comot cat* path/to/target
```
This will move or copy all files starting with `cat`.

### Filtering by File Type

- **Images**: Use the `-i` flag to filter images.
- **Videos**: Use the `-v` flag to filter videos.
- **Audio**: Use the `-a` flag to filter audio files.
- **Custom Extensions**: Use the `-e` flag followed by the extension.

Examples:
```bash
comot -i cat* /path/to/target   # Move or copy only image files
comot -v video* /path/to/target # Move or copy only video files
comot -e pdf report* /path/to/target # Move or copy only PDF files
```

### Special Commands

- **Version**: Display the current version of the tool.
  ```bash
  comot --version
  ```
- **Help**: Display help information.
  ```bash
  comot --help
  ```
- **Author**: Display author information.
  ```bash
  comot --author
  ```

## Flag Placement Flexibility

You can place flags (`-c`, `-i`, `-v`, etc.) either at the beginning, middle, or end of the command. The tool will correctly handle flag placement regardless of where it appears.

Examples:
```bash
comot -c cat.png path/to/target   # Flag at the beginning
comot cat.png -c path/to/target   # Flag in the middle
comot cat.png path/to/target -c   # Flag at the end
```

## Future Features
More features will be added in the future, including:
- More advanced filtering options.
- Customization for more file operations.

## Contributing
Feel free to fork this project, submit pull requests, or report issues!

## License
MIT License
