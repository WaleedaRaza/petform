#!/usr/bin/env python3
"""
Resize iPad screenshots to Apple's required dimensions for App Store Connect
"""

from PIL import Image
import os
import glob

def resize_screenshot(input_path, output_path, target_width, target_height):
    """Resize screenshot to target dimensions while maintaining aspect ratio"""
    try:
        with Image.open(input_path) as img:
            # Convert to RGB if necessary
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Resize to target dimensions
            resized_img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
            
            # Save with high quality
            resized_img.save(output_path, 'PNG', quality=95)
            print(f"✅ Resized: {os.path.basename(input_path)} → {os.path.basename(output_path)} ({target_width}x{target_height})")
            
    except Exception as e:
        print(f"❌ Error processing {input_path}: {e}")

def main():
    # Apple's required iPad screenshot dimensions
    ipad_dimensions = {
        "iPad_Pro_12.9inch": (2048, 2732),
        "iPad_Pro_11inch": (1668, 2388),
        "iPad_Air": (1640, 2360),
        "iPad_10th_gen": (1640, 2360),
        "iPad_mini": (1488, 2266)
    }
    
    # Find all screenshot files using glob pattern
    screenshot_files = glob.glob("Screenshot 2025-08-27 at 12.08*.png")
    
    if not screenshot_files:
        print("❌ No screenshot files found!")
        print("🔍 Looking for files matching pattern: Screenshot 2025-08-27 at 12.08*.png")
        return
    
    print(f"📱 Found {len(screenshot_files)} screenshot files:")
    for file in screenshot_files:
        print(f"   - {file}")
    
    # Create output directories
    for dimension_name in ipad_dimensions.keys():
        os.makedirs(f"app_store_screenshots_{dimension_name}", exist_ok=True)
    
    # Process each screenshot
    for screenshot_file in screenshot_files:
        print(f"\n📱 Processing: {screenshot_file}")
        
        # Resize to each required dimension
        for dimension_name, (width, height) in ipad_dimensions.items():
            output_dir = f"app_store_screenshots_{dimension_name}"
            output_file = os.path.join(output_dir, f"{dimension_name}_{os.path.basename(screenshot_file)}")
            
            resize_screenshot(screenshot_file, output_file, width, height)
    
    print(f"\n🎉 All screenshots resized! Check the app_store_screenshots_* folders.")
    print(f"📱 Upload these to App Store Connect with the correct device type.")

if __name__ == "__main__":
    main()
