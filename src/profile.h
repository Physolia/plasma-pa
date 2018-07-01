/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef PROFILE_H
#define PROFILE_H

#include <QObject>
#include <QString>

namespace QPulseAudio
{

class Profile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(quint32 priority READ priority NOTIFY priorityChanged)
    Q_PROPERTY(Availability availability READ availability NOTIFY availabilityChanged)
public:

    enum Availability {
        Unknown,
        Available,
        Unavailable
    };
    Q_ENUM(Availability)

    Profile(QObject *parent);
    ~Profile() override;

    template<typename PAInfo>
    void setInfo(const PAInfo *info)
    {
        setCommonInfo(info, info->available ? Available : Unavailable);
    }

    QString name() const;
    QString description() const;
    quint32 priority() const;
    Availability availability() const;

signals:
    void nameChanged();
    void descriptionChanged();
    void priorityChanged();
    void availabilityChanged();

protected:
    template<typename PAInfo>
    void setCommonInfo(const PAInfo *info, Availability newAvailability)
    {
        // Description is optional. Name not so much as we need some ID.
        Q_ASSERT(info->name);
        QString infoName = QString::fromUtf8(info->name);
        if (m_name != infoName) {
            m_name = infoName;
            emit nameChanged();
        }
        if (info->description) {
            QString infoDescription = QString::fromUtf8(info->description);
            if (m_description != infoDescription) {
                m_description = infoDescription;
                emit descriptionChanged();
            }
        }
        if (m_priority != info->priority) {
            m_priority = info->priority;
            emit priorityChanged();
        }

        if (m_availability != newAvailability) {
            m_availability = newAvailability;
            emit availabilityChanged();
        }
    }

private:
    QString m_name;
    QString m_description;
    quint32 m_priority;
    Availability m_availability;
};

} // QPulseAudio

#endif // PROFILE_H
