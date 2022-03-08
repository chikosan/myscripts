import argparse
import sys



def main(args=None):
    args = sys.argv[1:] if args is None else args

    # Get configuration arguments form jenkins pipeline
    parser = argparse.ArgumentParser(
        description="""
                PcloudSemver is a tool for calc the next version in your repo.
            """
    )
    parser.add_argument(
        "-version_base_on",
        "--version_base_on",
        required=False,
        type=str,
        dest="version_base_on",
        default="tags",
        help="Base on what to calc the next version Tag of File",
    )
    parser.add_argument(
        "-build_number",
        "--build_number",
        required=False,
        type=int,
        dest="jenkins_build",
        default=99,
        help="Jenkins build number",
    )
    parser.add_argument(
        "-debug",
        "--debug",
        required=False,
        type=bool,
        dest="is_debug",
        default=True,
        help="Show more information",
    )

    args = parser.parse_args()

    
    build_number=args.jenkins_build
    version_base_on=args.version_base_on
    debug_mode=args.is_debug
    
    print(f"debug_mode: {debug_mode}")
    print(f"debug_mode_type: {type(debug_mode)}")
    

if __name__ == "__main__":
    main()
