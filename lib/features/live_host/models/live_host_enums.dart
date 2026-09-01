library;

enum LiveHostStep { landing, storySelection, liveSettings, liveRoom }

enum LiveHostStatus { idle, connecting, live, closed, error }

enum LiveHostRoomType { listenOnly, interactive }

enum LiveHostPlayerStatus { paused, playing }

enum LiveHostPlayerPendingAction { none, play, pause, seek }
