# =================
# This script is used to build the project locally.
# It does the same thing as the GitHub Actions CI pipeline.
# =================

# Configure CMake project to generate bindings
cmake -S . -B build

# Copy all txt files from './output' to './website/public'
cp -r output/*.txt website/public

# Build the website
cd website
npm install
npm run build
cd ..