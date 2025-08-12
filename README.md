# donk_commands

A comprehensive admin commands script for FiveM servers running QBOX framework.

## Features

- Complete admin command suite
- Permission-based access control
- User-friendly interface
- Optimized for QBOX framework
- Built with modern FiveM development practices

## Requirements

- **QBOX Framework** - This script is designed exclusively for QBOX
- **ox_lib** - Required dependency for UI and utility functions
- FiveM server with appropriate permissions

## Installation

1. Download the latest release from the [Releases](../../releases) page
2. Extract the `donk_commands` folder to your server's `resources` directory
3. Add the following to your `server.cfg`:
   ```
   ensure ox_lib
   ensure donk_commands
   ```
4. Restart your server or use `refresh` and `start donk_commands`

## Dependencies

Make sure these resources are installed and running:
- [ox_lib](https://github.com/overextended/ox_lib)
- QBOX Framework

## Configuration

Configuration files can be found in the `config/` directory. Modify these files to customize:
- Command permissions
- Available commands
- User interface settings
- Framework-specific options

## Commands

*Command documentation will be available in the wiki or in-game help system*

## Permissions

This script uses QBOX's built-in permission system. Configure admin levels and permissions through your QBOX admin panel or configuration files.

## Support

- **Issues**: Report bugs and request features through [GitHub Issues](../../issues)
- **Discord**: Join our community discord for support and updates
- **Documentation**: Check the [Wiki](../../wiki) for detailed guides

## Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## Credits

- **Author**: [Your Name]
- **Framework**: QBOX Development Team
- **Dependencies**: Overextended (ox_lib)

---

⭐ If you find this script useful, please consider giving it a star!

## Disclaimer

This script is provided as-is. Always test thoroughly on a development server before deploying to production. The authors are not responsible for any issues that may arise from the use of this script.
