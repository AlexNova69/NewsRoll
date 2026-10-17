import QtQuick 2.3
import QtMultimedia 5.6

/* ============================================================================
   NewsRollAV.qml — опциональная видео-заставка для NewsRoll.qml
   (точная копия схемы WeatherRollAV.qml из WeatherRoll).

   Загружается главным скриптом через Loader. Если движок QML собран БЕЗ
   QtMultimedia (типично для некоторых сборок ForwardT), загрузка этого
   файла завершается ошибкой — Loader сообщает об этом, и NewsRoll
   переходит на статическую заставку. Благодаря выносу в отдельный файл
   основной скрипт остаётся работоспособным в любой сборке Qt.

   Интерфейс (вызывается из NewsRoll.qml):
     playIntro(url)   — видео-заставка в начале показа;
     stopAll()        — остановить и скрыть видео.
   Сигналы:
     introFinished()  — видео закончилось (далее -> beginShow());
     mediaError(tag, message) — ошибка (tag: "intro").
   Свойство:
     introDurationMs  — длительность видео после загрузки (для расчёта
                        длительности задания).
   ============================================================================ */

Item {
    id: av

    signal introFinished()
    signal mediaError(string tag, string message)

    property real videoVolume: 1.0      // громкость видео-заставки 0..1
    property int introDurationMs: 0     // длина видео (известна после загрузки)

    function playIntro(url) {
        splashVideo.visible = true
        splashVideo.volume = videoVolume
        splashVideo.source = url
        splashVideo.play()
    }

    function stopAll() {
        splashVideo.stop()
        splashVideo.visible = false
    }

    Video {
        id: splashVideo
        anchors.fill: parent
        autoPlay: false
        fillMode: VideoOutput.PreserveAspectCrop
        visible: false

        onStatusChanged: {
            if (status === MediaPlayer.LoadedMedia)
                av.introDurationMs = duration
            if (status === MediaPlayer.EndOfMedia) {
                visible = false
                av.introFinished()
            }
        }

        onError: {
            if (error !== MediaPlayer.NoError)
                av.mediaError("intro", errorString)
        }
    }
}
