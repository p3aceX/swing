package com.swing.live;

import J3.i;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import k.AbstractC0501s;
import q.m;

/* JADX INFO: loaded from: classes.dex */
public final class StreamForegroundService extends Service {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ int f3872a = 0;

    @Override // android.app.Service
    public final IBinder onBind(Intent intent) {
        return null;
    }

    @Override // android.app.Service
    public final void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= 26) {
            AbstractC0501s.m();
            NotificationChannel notificationChannelB = AbstractC0501s.b();
            notificationChannelB.setDescription("Notification for active live streaming sessions");
            ((NotificationManager) getSystemService(NotificationManager.class)).createNotificationChannel(notificationChannelB);
        }
    }

    @Override // android.app.Service
    public final int onStartCommand(Intent intent, int i4, int i5) {
        PendingIntent activity = PendingIntent.getActivity(this, 0, new Intent(this, (Class<?>) MainActivity.class), 201326592);
        m mVar = new m(this, "swing_live_streaming");
        mVar.e = m.b("SwingLive: Streaming active");
        mVar.f6227f = m.b("Broadcasting match to YouTube...");
        Notification notification = mVar.f6237p;
        notification.icon = android.R.drawable.ic_menu_camera;
        mVar.f6229h = 1;
        mVar.f6233l = "service";
        mVar.f6228g = activity;
        notification.flags |= 2;
        Notification notificationA = mVar.a();
        i.d(notificationA, "build(...)");
        startForeground(888, notificationA);
        return 1;
    }
}
