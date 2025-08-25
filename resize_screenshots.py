#!/usr/bin/env python3
"""
App Store Screenshot Resizer
Resizes screenshots to Apple's required dimensions
"""

import os
from PIL import Image
import sys

def resize_image(input_path, output_path, target_width, target_height):
    """Resize image to exact dimensions, maintaining aspect ratio with padding if needed"""
    try:
        # Open the image
        with Image.open(input_path) as img:
            # Convert to RGB if necessary
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Calculate the aspect ratios
            img_ratio = img.width / img.height
            target_ratio = target_width / target_height
            
            if img_ratio > target_ratio:
                # Image is wider than target, fit by width
                new_width = target_width
                new_height = int(target_width / img_ratio)
            else:
                # Image is taller than target, fit by height
                new_height = target_height
                new_width = int(target_height * img_ratio)
            
            # Resize the image
            resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
            
            # Create a new image with target dimensions and paste the resized image
            final_img = Image.new('RGB', (target_width, target_height), (255, 255, 255))  # White background
            
            # Calculate position to center the image
            x = (target_width - new_width) // 2
            y = (target_height - new_height) // 2
            
            final_img.paste(resized_img, (x, y))
            
            # Save the final image
            final_img.save(output_path, 'PNG', quality=95, optimize=True)
            print(f"✅ Resized: {os.path.basename(input_path)} → {target_width}×{target_height}")
            
            return True
            
    except Exception as e:
        print(f"❌ Error resizing {input_path}: {e}")
        return False

def main():
    # Define target dimensions for different iPhone sizes
    target_sizes = {
        "6.7inch": (1290, 2796),  # iPhone 14 Pro Max, 15 Pro Max
        "6.5inch": (1284, 2778),  # iPhone 11 Pro Max, 12 Pro Max, 13 Pro Max
        "5.5inch": (1242, 2208),  # iPhone 8 Plus
    }
    
    input_dir = "petform_pics"
    
    # Create output directories
    for size_name in target_sizes.keys():
        output_dir = f"app_store_screenshots_{size_name}"
        os.makedirs(output_dir, exist_ok=True)
    
    # Get all PNG files from input directory
    if not os.path.exists(input_dir):
        print(f"❌ Input directory '{input_dir}' not found!")
        return False
    
    png_files = [f for f in os.listdir(input_dir) if f.lower().endswith('.png')]
    
    if not png_files:
        print(f"❌ No PNG files found in '{input_dir}'!")
        return False
    
    print(f"📱 Found {len(png_files)} screenshot(s) to resize...")
    print("🔄 Resizing to App Store requirements...")
    
    success_count = 0
    
    # Resize each image for each target size
    for filename in png_files:
        input_path = os.path.join(input_dir, filename)
        
        for size_name, (width, height) in target_sizes.items():
            output_dir = f"app_store_screenshots_{size_name}"
            output_filename = f"{os.path.splitext(filename)[0]}_{size_name}.png"
            output_path = os.path.join(output_dir, output_filename)
            
            if resize_image(input_path, output_path, width, height):
                success_count += 1
    
    print(f"\n✅ Successfully resized {success_count} images!")
    print("\n📁 Output directories:")
    for size_name in target_sizes.keys():
        output_dir = f"app_store_screenshots_{size_name}"
        file_count = len([f for f in os.listdir(output_dir) if f.endswith('.png')])
        print(f"   📱 {output_dir}/ ({file_count} files)")
    
    print("\n🎯 Next steps:")
    print("1. Use the 6.7inch screenshots for iPhone 6.7\" in App Store Connect")
    print("2. Use the 5.5inch screenshots for iPhone 5.5\" in App Store Connect")
    print("3. Upload 3-10 screenshots per device size")
    
    return True

if __name__ == "__main__":
    main()
