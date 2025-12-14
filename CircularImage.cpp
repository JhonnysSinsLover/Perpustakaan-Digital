#include "CircularImage.h"
#include <QImageReader>
#include <QPainterPath>
#include <QFileInfo>
#include <QNetworkRequest>
#include <QDebug>

CircularImage::CircularImage(QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_smooth(true)
    , m_antialiasing(true)
    , m_borderWidth(0)
    , m_borderColor(Qt::transparent)
    , m_status(Null)
    , m_networkManager(new QNetworkAccessManager(this))
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAntialiasing(true);
    setSmooth(true);
}

void CircularImage::setSource(const QUrl &source)
{
    if (m_source == source)
        return;

    m_source = source;
    emit sourceChanged();
    
    if (source.isEmpty()) {
        m_originalImage = QImage();
        m_circularImage = QImage();
        setStatus(Null);
        update();
        return;
    }

    setStatus(Loading);
    loadImage();
}

void CircularImage::setSmooth(bool smooth)
{
    if (m_smooth == smooth)
        return;

    m_smooth = smooth;
    emit smoothChanged();
    update();
}

void CircularImage::setAntialiasing(bool antialiasing)
{
    if (m_antialiasing == antialiasing)
        return;

    m_antialiasing = antialiasing;
    emit antialiasingChanged();
    update();
}

void CircularImage::setBorderWidth(qreal width)
{
    if (qFuzzyCompare(m_borderWidth, width))
        return;

    m_borderWidth = width;
    emit borderWidthChanged();
    update();
}

void CircularImage::setBorderColor(const QColor &color)
{
    if (m_borderColor == color)
        return;

    m_borderColor = color;
    emit borderColorChanged();
    update();
}

void CircularImage::loadImage()
{
    QString localPath = urlToLocalPath(m_source);
    
    if (localPath.isEmpty()) {
        qWarning() << "CircularImage: Invalid source path:" << m_source;
        setStatus(Error);
        return;
    }

    QFileInfo fileInfo(localPath);
    if (!fileInfo.exists()) {
        qWarning() << "CircularImage: File does not exist:" << localPath;
        setStatus(Error);
        return;
    }

    QImageReader reader(localPath);
    if (!reader.canRead()) {
        qWarning() << "CircularImage: Cannot read image:" << localPath;
        setStatus(Error);
        return;
    }

    m_originalImage = reader.read();
    if (m_originalImage.isNull()) {
        qWarning() << "CircularImage: Failed to load image:" << reader.errorString();
        setStatus(Error);
        return;
    }

    onImageLoaded();
}

void CircularImage::onImageLoaded()
{
    if (m_originalImage.isNull()) {
        setStatus(Error);
        return;
    }

    // Get the target size based on the item's size
    int targetSize = qMin(static_cast<int>(width()), static_cast<int>(height()));
    if (targetSize <= 0) {
        targetSize = 100; // Default size
    }

    // Create circular image
    m_circularImage = createCircularImage(m_originalImage, targetSize);
    
    setStatus(Ready);
    update();
}

QImage CircularImage::createCircularImage(const QImage &sourceImage, int size)
{
    if (sourceImage.isNull() || size <= 0)
        return QImage();

    // Create output image with alpha channel
    QImage circularImage(size, size, QImage::Format_ARGB32_Premultiplied);
    circularImage.fill(Qt::transparent);

    QPainter painter(&circularImage);
    
    // Enable high quality rendering
    if (m_antialiasing) {
        painter.setRenderHint(QPainter::Antialiasing, true);
        painter.setRenderHint(QPainter::SmoothPixmapTransform, true);
    }
    
    if (m_smooth) {
        painter.setRenderHint(QPainter::SmoothPixmapTransform, true);
    }

    // Create circular clipping path
    QPainterPath clipPath;
    qreal radius = size / 2.0;
    clipPath.addEllipse(0, 0, size, size);
    
    // Apply circular clipping
    painter.setClipPath(clipPath);
    
    // Scale source image to fit the circle while maintaining aspect ratio
    QImage scaledImage = sourceImage.scaled(size, size, Qt::KeepAspectRatioByExpanding, 
                                          m_smooth ? Qt::SmoothTransformation : Qt::FastTransformation);
    
    // Center the scaled image
    int offsetX = (scaledImage.width() - size) / 2;
    int offsetY = (scaledImage.height() - size) / 2;
    
    // Draw the image
    painter.drawImage(-offsetX, -offsetY, scaledImage);
    
    // Reset clipping for border
    painter.setClipping(false);
    
    // Draw border if specified
    if (m_borderWidth > 0 && m_borderColor.alpha() > 0) {
        QPen borderPen(m_borderColor);
        borderPen.setWidthF(m_borderWidth);
        borderPen.setStyle(Qt::SolidLine);
        painter.setPen(borderPen);
        painter.setBrush(Qt::NoBrush);
        
        qreal borderRadius = radius - (m_borderWidth / 2.0);
        painter.drawEllipse(QRectF(m_borderWidth / 2.0, m_borderWidth / 2.0, 
                                  size - m_borderWidth, size - m_borderWidth));
    }

    return circularImage;
}

void CircularImage::paint(QPainter *painter)
{
    if (m_circularImage.isNull())
        return;

    // Ensure high quality rendering
    if (m_antialiasing) {
        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
    }
    
    if (m_smooth) {
        painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
    }

    // Get the drawing area
    QRectF targetRect(0, 0, width(), height());
    
    // Draw the circular image
    painter->drawImage(targetRect, m_circularImage);
}

QString CircularImage::urlToLocalPath(const QUrl &url)
{
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }
    
    if (url.scheme().isEmpty() || url.scheme() == "file") {
        QString path = url.toString();
        
        // Handle file:/// URLs
        if (path.startsWith("file:///")) {
            path = path.mid(8); // Remove "file:///"
        } else if (path.startsWith("file://")) {
            path = path.mid(7); // Remove "file://"
        }
        
        // Convert forward slashes to native path separators on Windows
        #ifdef Q_OS_WIN
        path = path.replace('/', '\\');
        #endif
        
        return path;
    }
    
    // For other schemes, return empty (not supported for now)
    return QString();
}

void CircularImage::setStatus(Status status)
{
    if (m_status == status)
        return;
        
    m_status = status;
    emit statusChanged();
}

void CircularImage::onNetworkReplyFinished()
{
    // This can be used for remote image loading in the future
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply)
        return;
        
    reply->deleteLater();
}
