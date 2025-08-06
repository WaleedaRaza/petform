-- FIX: Update tracking_metrics table to match app requirements
-- This addresses the underlying schema mismatch

-- First, let's see what we have
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tracking_metrics' 
ORDER BY ordinal_position;

-- Drop and recreate the table with the correct schema
DROP TABLE IF EXISTS tracking_metrics CASCADE;

CREATE TABLE public.tracking_metrics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Health',
  unit TEXT DEFAULT '',
  target_value DECIMAL(10,2) DEFAULT 0.0,
  current_value DECIMAL(10,2) DEFAULT 0.0,
  frequency TEXT DEFAULT 'daily',
  description TEXT DEFAULT '',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pet metrics" ON tracking_metrics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own pet metrics" ON tracking_metrics
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own pet metrics" ON tracking_metrics
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own pet metrics" ON tracking_metrics
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  ); 