# OpenAir Privacy Policy

This Privacy Policy describes how OpenAir ("we," "us," or "our") collects, uses, and shares information when you use our mobile application (the "App").

## 1. Information We Do Not Collect

OpenAir is designed with your privacy in mind. We do not collect, store, or transmit any personally identifiable information about you without your explicit consent.

Specifically:

*   **No Personal Data Collection:** We do not collect any personal data that could directly identify you unless you choose to create an account and enable cloud sync.
*   **No Usage Data Collection:** We do not collect analytics, crash reports, or usage statistics.
*   **No Third-Party Analytics:** We do not use third-party analytics services (e.g., Google Analytics, Firebase Analytics).
*   **No Advertising:** The App does not display advertisements and therefore does not collect data for advertising purposes.

## 2. Information You Provide (Locally Stored)

All your preferences, subscribed podcasts, listening history, and other app-related data are stored **locally on your device only** by default. This data is not transmitted to us or any third parties unless you explicitly choose to create an account and enable cloud synchronization.

We use the following local storage mechanisms:
- **Hive** for key-value data (settings, subscriptions, queue, history)
- **SQLite** for structured data (export/import snapshots)

This data remains on your device and is under your control at all times.

## 3. Authentication and Cloud Sync (Optional)

OpenAir offers an **optional** account system powered by **Supabase** that enables cloud synchronization across your devices.

### Account Creation

If you choose to create an account, you may sign up using **email and password**.

The following information is stored by Supabase when you create an account:
- Your email address
- A username of your choice
- A unique internal user ID assigned to your account

### Cloud Sync Data

If you enable cloud synchronization, the following data is synced to Supabase and associated with your account:
- **Subscribed podcasts** (feed URLs and metadata)
- **Listening history** (episodes you have listened to)
- **Playback queue** (your current episode queue)
- **Favorite episodes** (episodes you have marked as favorites)
- **Playback positions** (your progress within episodes, including timestamps)
- **App settings** (UI preferences, playback settings, sync configuration, notification settings)

You can configure which categories of data are synced in the app settings. Each sync category can be enabled or disabled independently.

### User Control

- **Data Access:** You can view and manage your synced data at any time from within the App.
- **Account Deletion:** You may delete your account and all associated data at any time through the App settings. This will remove all your personal information from our systems, including all synced data.
- **Opt-Out:** You may disable cloud sync at any time. Your locally stored data will remain intact and functional.

## 4. Third-Party Services

OpenAir relies on the following third-party services to provide its core functionality:

*   **PodcastIndex API:** The App fetches podcast information (e.g., podcast titles, descriptions, episode lists, audio URLs) from the PodcastIndex API. When you use the App to browse or search for podcasts, your requests are sent to the PodcastIndex API. We do not control the data collected by PodcastIndex. Please refer to the [PodcastIndex Privacy Policy](https://podcastindex.org/privacy) for more information on their data practices.

*   **Fyyd API (Optional):** For additional podcast discovery, the App may optionally fetch podcast information from the Fyyd API. Similar to PodcastIndex, when you use features that utilize Fyyd, your requests are sent to the Fyyd API. We do not control the data collected by Fyyd. Please refer to the [Fyyd Privacy Policy](https://fyyd.de/privacy) for more information on their data practices.

*   **Supabase:** If you choose to create an account and enable cloud sync, Supabase acts as our authentication provider and database backend. Your account information and synced data are stored on Supabase's infrastructure. Please refer to the [Supabase Privacy Policy](https://supabase.com/privacy) for more information on their data practices.

## 5. Data Security

We take the security of your data seriously:
- All network communications with Supabase and podcast APIs are encrypted using TLS/HTTPS.
- Authentication is handled securely by Supabase using industry-standard protocols (JWT).
- Passwords are never stored by us; they are handled entirely by Supabase's authentication system.
- Your locally stored data is not encrypted at rest by the App, as it resides solely on your device and is not accessible to other applications under standard platform security controls.

## 6. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.

## 7. Contact Us

If you have any questions about this Privacy Policy, please contact us by opening an issue on our GitHub repository: [https://github.com/OpenAir-Podcast/openair/issues](https://github.com/OpenAir-Podcast/openair/issues)
