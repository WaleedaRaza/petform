# PetForm - All-in-One Pet Management App

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-10.7.0-orange.svg)](https://firebase.google.com/)
[![Supabase](https://img.shields.io/badge/Supabase-2.38.0-green.svg)](https://supabase.com/)
[![Auth0](https://img.shields.io/badge/Auth0-2.3.0-purple.svg)](https://auth0.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4-green.svg)](https://openai.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue.svg)](https://flutter.dev/)

> **Comprehensive pet management app with AI-powered insights, health tracking, community engagement, and smart shopping. Built with Flutter, Auth0, Supabase, and OpenAI GPT-4.**

## 📊 Project Overview

- **🏗️ Architecture**: Flutter app with Auth0 authentication and Supabase backend
- **📱 Platforms**: iOS and Android with responsive design
- **🤖 AI Integration**: OpenAI GPT-4 for personalized pet advice
- **📊 Tracking**: Comprehensive health and behavior metrics
- **🌐 Community**: Curated Reddit content with smart filtering
- **🛒 Shopping**: AI-driven product recommendations
- **🔐 Security**: Auth0 with social login and secure token management

## 🚀 Overview

PetForm is a comprehensive pet management app that helps pet owners track their pets' health, get AI-powered advice, engage with the community, and manage shopping needs. Built with Flutter, it provides a seamless experience across iOS and Android platforms.

### Core Features

- **🤖 AI Pet Assistant** - GPT-4 powered chat for health, behavior, and nutrition advice
- **📊 Health Tracking** - Monitor weight, feeding, exercise, grooming, and medication schedules
- **🌐 Community Feed** - Curated Reddit content with smart filtering and balanced assortment
- **🛒 Shopping Lists** - AI-driven product recommendations and shopping management
- **🔐 Secure Auth** - Auth0 authentication with social login (Google, Apple)
- **📱 Cross-Platform** - Native iOS and Android apps with responsive design
- **⚡ Real-Time Data** - Supabase backend with live synchronization

## 🏗️ Technical Architecture

### System Overview
```
┌─────────────────┐
│   Flutter App   │
│  (iOS/Android)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Auth0 Auth    │
│  (Social Login) │
└─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐
│   Supabase      │    │   OpenAI        │
│  (PostgreSQL)   │    │   (GPT-4 API)   │
└─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   Reddit API    │    │   Firebase      │
│  (Community)    │    │  (Real-time)    │
└─────────────────┘    └─────────────────┘
```

## 🔧 Core Features

### 🤖 AI Pet Assistant


**AI Features:**
- **GPT-4 Integration** - Natural language processing for pet advice
- **Context-Aware Responses** - AI considers pet breed, age, and health history
- **Health & Behavior Advice** - Personalized recommendations based on pet data
- **Nutrition Guidance** - Diet recommendations and feeding schedules
- **Emergency Advice** - Quick responses for urgent pet care situations
- **Multi-turn Conversations** - Maintains context throughout the conversation

### 📊 Health Tracking System

**Tracking Features:**
- **Multiple Categories** - Weight, feeding, exercise, grooming, medication
- **Custom Metrics** - Add personalized tracking for specific needs
- **Progress Tracking** - Monitor trends and set goals
- **Default Metrics** - Pre-configured tracking for common pet care needs
- **Data Persistence** - Store tracking data in Supabase with real-time sync
- **Visual Progress** - Charts and graphs for tracking visualization

### 🌐 Community Feed
**Community Features:**
- **Reddit Integration** - Curated posts from popular pet subreddits
- **Smart Filtering** - AI-powered inappropriate content detection
- **Balanced Content** - Mix of different pet types and topics
- **Pet-Specific Filters** - Filter content by pet type (Dog, Cat, etc.)
- **Real-Time Updates** - Live feed with new posts
- **Save Posts** - Bookmark interesting posts for later
- **Comments** - View and add comments to posts

### 🛒 Shopping Lists
**Shopping Features:**
- **Add Items** - Add pet supplies to shopping list
- **Categories** - Organize items by type (Food, Toys, Health, etc.)
- **Purchase Tracking** - Mark items as purchased
- **My List** - Personal shopping list management
- **Item Management** - Add, remove, and edit shopping items

## 📱 App Features

### Pet Management
- **Add Pets** - Create profiles for multiple pets
- **Pet Details** - Store breed, age, weight, and health information
- **Pet Photos** - Upload and manage pet photos
- **Health Records** - Track medical history and appointments

### User Interface
- **Dark Theme** - Modern dark-themed interface
- **Responsive Design** - Optimized for different screen sizes
- **Intuitive Navigation** - Easy-to-use tab-based navigation
- **Real-Time Updates** - Live data synchronization across devices

### Data Management
- **Offline Support** - Works without internet connection
- **Data Sync** - Automatic synchronization when online
- **Export Data** - Backup and export pet information
- **Privacy Controls** - User data protection and control

## 🔬 Technical Deep Dive

### Architecture Overview

**System Architecture:**
- **Presentation Layer** - Flutter UI with responsive design and dark theme
- **Business Logic Layer** - Provider pattern for state management
- **Data Access Layer** - Service classes for API communication
- **External APIs** - Auth0, Supabase, OpenAI, Reddit integration

### Authentication & Security

**Authentication Process:**
1. **Social Login** - User authenticates with Google/Apple via Auth0
2. **Token Validation** - JWT token validated and user claims extracted
3. **User Mapping** - Auth0 user ID mapped to Supabase UUID via custom RPC
4. **Profile Sync** - User profile created/updated in Supabase
5. **Session Management** - Secure token storage and refresh handling

**Security Features:**
- **Secure Storage** - Encrypted local storage for sensitive data
- **Token Management** - Secure JWT handling with automatic refresh
- **Data Validation** - Server-side and client-side validation
- **Row Level Security** - Database-level user data isolation

### Performance & State Management

**Performance Features:**
- **Lazy Loading** - Load data on-demand to reduce initial load time
- **Image Optimization** - Compressed images with caching
- **Memory Management** - Proper disposal of resources
- **Offline Support** - Local state persistence with sync

**State Management:**
- **Provider Pattern** - Centralized state management with reactive updates
- **Error Handling** - Graceful error states and recovery
- **Loading States** - User feedback during async operations

### Database & API Integration

**Database Features:**
- **Row Level Security (RLS)** - User data isolation with custom policies
- **Strategic Indexing** - Optimized queries for common operations
- **Real-time Subscriptions** - Live data updates via WebSocket
- **Data Validation** - Server-side validation with custom functions

**API Integration:**
- **Retry Logic** - Automatic retry for failed requests
- **Caching Strategy** - Local caching for frequently accessed data
- **Error Recovery** - Graceful degradation and user feedback

### Version 2.0 - Enhanced AI & Social Features (Q1 2026)

**Planned Features:**
- **Pet Social Network** - Find nearby pets and schedule playdates
- **Pet Sitter Marketplace** - Book verified pet sitters in your area
- **Veterinary Integration** - Direct appointment booking with local vets
- **Pet Insurance Quotes** - Compare and purchase pet insurance policies
- **Advanced Tracking** - GPS tracking for outdoor pets with activity monitoring
- **Pet Training Videos** - Curated training content with progress tracking
- **Emergency Alerts** - 24/7 emergency response with vet routing
- **Professional Services** - Book grooming, training, and veterinary services
- **Breeder Network** - Reputable breeder directory with reviews
- **Pet Photography** - Professional pet photo sessions
- **Photo Analysis** - AI-powered breed identification and health assessment from photos
- **Voice Assistant** - Natural language voice interface for hands-free operation
- **Predictive Health** - ML models to predict potential health issues based on trends

⭐ Star this repository if you find it helpful!

🔄 Fork and contribute to make it even better!

📧 Contact for collaboration opportunities!
