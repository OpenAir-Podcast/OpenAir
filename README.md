# OpenAir: Breathe Life into Your Podcast Journey

OpenAir is a free and open-source podcast app built with Flutter, empowering you to explore and enjoy the world of audio storytelling. Dive into a vast library of podcasts, personalize your listening experience, and connect with a vibrant community of fellow enthusiasts.

## Key Features

- Explore: Discover a diverse range of podcasts with intuitive browsing by category, popularity, and personalized recommendations.
- Listen: Stream podcasts seamlessly with smooth playback controls and offline listening capabilities for uninterrupted enjoyment.
- Organize: Create custom playlists, manage subscriptions efficiently, and track your listening progress effortlessly.
- Share: Recommend your favorite podcasts to friends and contribute to the OpenAir community by suggesting features and shaping the future of the app.

## Built with Openness in Mind

OpenAir embraces open-source principles. The codebase is freely accessible, allowing anyone to contribute, report issues, and propose improvements. We believe in fostering a collaborative environment to create the best possible podcast experience for everyone.

## Get Involved:

Clone the repository: https://github.com/LiquidHive/openair.git

Read the contribution guidelines: [click here for contribution guidelines](https://github.com/LiquidHive/openair/blob/main/Contribution%20Guidelines.md)

Join the discussion: [click here for discussion](https://github.com/LiquidHive/openair/discussions)

## Getting Started

OpenAir fetches podcast information from the [PodcastIndex API](https://podcastindex.org/). To run OpenAir, you will need to obtain your own API credentials from PodcastIndex.

**Prerequisites:**

- Flutter development environment set up ([refer to official Flutter documentation](https://docs.flutter.dev/get-started/codelab))
- A **PodcastIndex API Key** and **API Secret**. You can get these by creating a free account at [https://api.podcastindex.org/developer_home](https://api.podcastindex.org/developer_home).

**Running the App:**

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/LiquidHive/openair.git](https://github.com/LiquidHive/openair.git)
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd OpenAir
    ```
3.  **Create a `.env` file** in the root of the `OpenAir` project directory.
4.  **Add your PodcastIndex API credentials to the `.env` file:**
    ```env
    PODCASTINDEX_API_KEY=YOUR_API_KEY_HERE
    PODCASTINDEX_API_SECRET=YOUR_API_SECRET_HERE
    ```
    **Important:** Replace `YOUR_API_KEY_HERE` and `YOUR_API_SECRET_HERE` with your actual API key and secret from the PodcastIndex developer portal.
5.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
6.  **Run the app on your device or emulator:**
    ```bash
    flutter run
    ```

## Contributing

We welcome contributions of all kinds! Please refer to the contribution guidelines document (link above) for details on how to get started.

## License

OpenAir is licensed under the MIT License (see LICENSE file for details).

## About LiquidHive

OpenAir is proudly developed and maintained by LiquidHive, a passionate team dedicated to building open-source tools for the community.

We hope you enjoy using OpenAir!
