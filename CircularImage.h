#ifndef CIRCULARIMAGE_H
#define CIRCULARIMAGE_H

#include <QQuickPaintedItem>
#include <QUrl>
#include <QImage>
#include <QPainter>
#include <QQuickItemGrabResult>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class CircularImage : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool smooth READ smooth WRITE setSmooth NOTIFY smoothChanged)
    Q_PROPERTY(bool antialiasing READ antialiasing WRITE setAntialiasing NOTIFY antialiasingChanged)
    Q_PROPERTY(qreal borderWidth READ borderWidth WRITE setBorderWidth NOTIFY borderWidthChanged)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)

public:
    enum Status {
        Null = 0,
        Ready,
        Loading,
        Error
    };
    Q_ENUM(Status)

    explicit CircularImage(QQuickItem *parent = nullptr);

    // Property getters
    QUrl source() const { return m_source; }
    bool smooth() const { return m_smooth; }
    bool antialiasing() const { return m_antialiasing; }
    qreal borderWidth() const { return m_borderWidth; }
    QColor borderColor() const { return m_borderColor; }
    Status status() const { return m_status; }

    // Property setters
    void setSource(const QUrl &source);
    void setSmooth(bool smooth);
    void setAntialiasing(bool antialiasing);
    void setBorderWidth(qreal width);
    void setBorderColor(const QColor &color);

    // QQuickPaintedItem interface
    void paint(QPainter *painter) override;

signals:
    void sourceChanged();
    void smoothChanged();
    void antialiasingChanged();
    void borderWidthChanged();
    void borderColorChanged();
    void statusChanged();

private slots:
    void onImageLoaded();
    void onNetworkReplyFinished();

private:
    void loadImage();
    void setStatus(Status status);
    QImage createCircularImage(const QImage &sourceImage, int size);
    QString urlToLocalPath(const QUrl &url);

    QUrl m_source;
    QImage m_originalImage;
    QImage m_circularImage;
    bool m_smooth;
    bool m_antialiasing;
    qreal m_borderWidth;
    QColor m_borderColor;
    Status m_status;
    QNetworkAccessManager *m_networkManager;
};

#endif // CIRCULARIMAGE_H
