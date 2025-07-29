-- Create shopping_items table with all fields needed for ShoppingItem model
CREATE TABLE IF NOT EXISTS shopping_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT,
    priority TEXT,
    estimated_cost DECIMAL(10,2),
    pet_id UUID,
    description TEXT,
    brand TEXT,
    store TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    tags TEXT[], -- Array of strings
    image_url TEXT,
    quantity INTEGER DEFAULT 1,
    notes TEXT,
    chewy_url TEXT,
    rating DECIMAL(3,2),
    review_count INTEGER,
    in_stock BOOLEAN,
    auto_ship BOOLEAN,
    free_shipping BOOLEAN,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_shopping_items_user_id ON shopping_items(user_id);
CREATE INDEX IF NOT EXISTS idx_shopping_items_category ON shopping_items(category);
CREATE INDEX IF NOT EXISTS idx_shopping_items_pet_id ON shopping_items(pet_id);

-- Enable RLS
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own shopping items" ON shopping_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own shopping items" ON shopping_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own shopping items" ON shopping_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own shopping items" ON shopping_items
    FOR DELETE USING (auth.uid() = user_id); 