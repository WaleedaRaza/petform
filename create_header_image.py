#!/usr/bin/env python3
"""
App Store Header Image Generator
Creates a 1800x1200 header image for PetForm
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_header_image():
    """Create a professional header image for PetForm"""
    
    # Create a new image with App Store requirements
    width, height = 1800, 1200
    img = Image.new('RGB', (width, height), color='#4A90E2')  # Pet-friendly blue
    
    # Create a gradient effect
    draw = ImageDraw.Draw(img)
    for y in range(height):
        # Create a subtle gradient from top to bottom
        r = int(74 + (y / height) * 20)  # 74 to 94
        g = int(144 + (y / height) * 20)  # 144 to 164
        b = int(226 + (y / height) * 20)  # 226 to 246
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Add a subtle pattern overlay
    for x in range(0, width, 100):
        for y in range(0, height, 100):
            if (x + y) % 200 == 0:
                draw.ellipse([x, y, x + 50, y + 50], fill=(255, 255, 255, 30))
    
    # Add main title
    try:
        # Try to use a system font, fallback to default if not available
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 120)
    except:
        title_font = ImageFont.load_default()
    
    title = "PetForm"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_height = title_bbox[3] - title_bbox[1]
    
    # Center the title
    title_x = (width - title_width) // 2
    title_y = (height - title_height) // 2 - 100
    
    # Add title with shadow effect
    draw.text((title_x + 3, title_y + 3), title, fill=(0, 0, 0, 100), font=title_font)
    draw.text((title_x, title_y), title, fill=(255, 255, 255), font=title_font)
    
    # Add subtitle
    try:
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
    except:
        subtitle_font = ImageFont.load_default()
    
    subtitle = "Your Pet Management Companion"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = title_y + title_height + 50
    
    draw.text((subtitle_x, subtitle_y), subtitle, fill=(255, 255, 255), font=subtitle_font)
    
    # Add pet icons
    pet_icons = ["🐕", "🐱", "🐦", "🐠", "🐹"]
    icon_size = 80
    icon_spacing = 120
    start_x = (width - (len(pet_icons) * icon_spacing)) // 2
    icon_y = subtitle_y + 100
    
    for i, icon in enumerate(pet_icons):
        icon_x = start_x + (i * icon_spacing)
        # Create a simple icon representation
        draw.ellipse([icon_x, icon_y, icon_x + icon_size, icon_y + icon_size], 
                    fill=(255, 255, 255, 200), outline=(255, 255, 255, 255), width=3)
        # Add icon text (emoji won't render, so use text)
        icon_text = icon if icon in ["🐕", "🐱"] else "🐾"
        try:
            icon_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        except:
            icon_font = ImageFont.load_default()
        
        icon_bbox = draw.textbbox((0, 0), icon_text, font=icon_font)
        icon_text_width = icon_bbox[2] - icon_bbox[0]
        icon_text_height = icon_bbox[3] - icon_bbox[1]
        
        icon_text_x = icon_x + (icon_size - icon_text_width) // 2
        icon_text_y = icon_y + (icon_size - icon_text_height) // 2
        
        draw.text((icon_text_x, icon_text_y), icon_text, fill=(74, 144, 226), font=icon_font)
    
    # Add tagline at bottom
    try:
        tagline_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
    except:
        tagline_font = ImageFont.load_default()
    
    tagline = "AI-Powered • Health Tracking • Community"
    tagline_bbox = draw.textbbox((0, 0), tagline, font=tagline_font)
    tagline_width = tagline_bbox[2] - tagline_bbox[0]
    
    tagline_x = (width - tagline_width) // 2
    tagline_y = height - 100
    
    draw.text((tagline_x, tagline_y), tagline, fill=(255, 255, 255, 200), font=tagline_font)
    
    # Save the image
    output_path = "petform_header_image.png"
    img.save(output_path, 'PNG', quality=95, optimize=True)
    
    print(f"✅ Header image created: {output_path}")
    print(f"📏 Dimensions: {width} × {height} pixels")
    print(f"🎨 Format: PNG (RGB)")
    print(f"📁 Ready to upload to App Store Connect!")
    
    return output_path

if __name__ == "__main__":
    create_header_image()
