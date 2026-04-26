package q;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.core.graphics.drawable.IconCompat;
import java.util.ArrayList;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f6223a;
    public CharSequence e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public CharSequence f6227f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public PendingIntent f6228g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f6229h;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public com.google.android.gms.common.internal.r f6231j;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public String f6233l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Bundle f6234m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public String f6235n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final boolean f6236o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final Notification f6237p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final ArrayList f6238q;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f6224b = new ArrayList();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f6225c = new ArrayList();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f6226d = new ArrayList();

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final boolean f6230i = true;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public boolean f6232k = false;

    public m(Context context, String str) {
        Notification notification = new Notification();
        this.f6237p = notification;
        this.f6223a = context;
        this.f6235n = str;
        notification.when = System.currentTimeMillis();
        notification.audioStreamType = -1;
        this.f6229h = 0;
        this.f6238q = new ArrayList();
        this.f6236o = true;
    }

    public static CharSequence b(String str) {
        return (str != null && str.length() > 5120) ? str.subSequence(0, 5120) : str;
    }

    public final Notification a() {
        CharSequence charSequence;
        Bundle bundle;
        int i4;
        ArrayList arrayList;
        int i5;
        new ArrayList();
        Bundle bundle2 = new Bundle();
        Notification.Builder builderA = Build.VERSION.SDK_INT >= 26 ? r.a(this.f6223a, this.f6235n) : new Notification.Builder(this.f6223a);
        Notification notification = this.f6237p;
        builderA.setWhen(notification.when).setSmallIcon(notification.icon, notification.iconLevel).setContent(notification.contentView).setTicker(notification.tickerText, null).setVibrate(notification.vibrate).setLights(notification.ledARGB, notification.ledOnMS, notification.ledOffMS).setOngoing((notification.flags & 2) != 0).setOnlyAlertOnce((notification.flags & 8) != 0).setAutoCancel((notification.flags & 16) != 0).setDefaults(notification.defaults).setContentTitle(this.e).setContentText(this.f6227f).setContentInfo(null).setContentIntent(this.f6228g).setDeleteIntent(notification.deleteIntent).setFullScreenIntent(null, (notification.flags & 128) != 0).setNumber(0).setProgress(0, 0, false);
        p.b(builderA, null);
        builderA.setSubText(null).setUsesChronometer(false).setPriority(this.f6229h);
        for (l lVar : this.f6224b) {
            if (lVar.f6218b == null && (i5 = lVar.e) != 0) {
                lVar.f6218b = IconCompat.b(i5);
            }
            IconCompat iconCompat = lVar.f6218b;
            Notification.Action.Builder builderA2 = p.a(iconCompat != null ? u.b.c(iconCompat, null) : null, lVar.f6221f, lVar.f6222g);
            Bundle bundle3 = lVar.f6217a;
            Bundle bundle4 = bundle3 != null ? new Bundle(bundle3) : new Bundle();
            boolean z4 = lVar.f6219c;
            bundle4.putBoolean("android.support.allowGeneratedReplies", z4);
            int i6 = Build.VERSION.SDK_INT;
            q.a(builderA2, z4);
            bundle4.putInt("android.support.action.semanticAction", 0);
            if (i6 >= 28) {
                s.b(builderA2, 0);
            }
            if (i6 >= 29) {
                t.c(builderA2, false);
            }
            if (i6 >= 31) {
                u.a(builderA2, false);
            }
            bundle4.putBoolean("android.support.action.showsUserInterface", lVar.f6220d);
            n.b(builderA2, bundle4);
            n.a(builderA, n.d(builderA2));
        }
        Bundle bundle5 = this.f6234m;
        if (bundle5 != null) {
            bundle2.putAll(bundle5);
        }
        int i7 = Build.VERSION.SDK_INT;
        builderA.setShowWhen(this.f6230i);
        n.i(builderA, this.f6232k);
        n.g(builderA, null);
        n.j(builderA, null);
        n.h(builderA, false);
        o.b(builderA, this.f6233l);
        o.c(builderA, 0);
        o.f(builderA, 0);
        o.d(builderA, null);
        o.e(builderA, notification.sound, notification.audioAttributes);
        ArrayList arrayList2 = this.f6238q;
        ArrayList arrayList3 = this.f6225c;
        if (i7 < 28) {
            if (arrayList3 == null) {
                arrayList = null;
            } else {
                arrayList = new ArrayList(arrayList3.size());
                Iterator it = arrayList3.iterator();
                if (it.hasNext()) {
                    it.next().getClass();
                    throw new ClassCastException();
                }
            }
            if (arrayList != null) {
                if (arrayList2 == null) {
                    arrayList2 = arrayList;
                } else {
                    n.c cVar = new n.c(arrayList2.size() + arrayList.size());
                    cVar.addAll(arrayList);
                    cVar.addAll(arrayList2);
                    arrayList2 = new ArrayList(cVar);
                }
            }
        }
        if (arrayList2 != null && !arrayList2.isEmpty()) {
            Iterator it2 = arrayList2.iterator();
            while (it2.hasNext()) {
                o.a(builderA, (String) it2.next());
            }
        }
        ArrayList arrayList4 = this.f6226d;
        if (arrayList4.size() > 0) {
            if (this.f6234m == null) {
                this.f6234m = new Bundle();
            }
            Bundle bundle6 = this.f6234m.getBundle("android.car.EXTENSIONS");
            if (bundle6 == null) {
                bundle6 = new Bundle();
            }
            Bundle bundle7 = new Bundle(bundle6);
            Bundle bundle8 = new Bundle();
            for (int i8 = 0; i8 < arrayList4.size(); i8++) {
                String string = Integer.toString(i8);
                l lVar2 = (l) arrayList4.get(i8);
                Bundle bundle9 = new Bundle();
                if (lVar2.f6218b == null && (i4 = lVar2.e) != 0) {
                    lVar2.f6218b = IconCompat.b(i4);
                }
                IconCompat iconCompat2 = lVar2.f6218b;
                bundle9.putInt("icon", iconCompat2 != null ? iconCompat2.c() : 0);
                bundle9.putCharSequence("title", lVar2.f6221f);
                bundle9.putParcelable("actionIntent", lVar2.f6222g);
                Bundle bundle10 = lVar2.f6217a;
                Bundle bundle11 = bundle10 != null ? new Bundle(bundle10) : new Bundle();
                bundle11.putBoolean("android.support.allowGeneratedReplies", lVar2.f6219c);
                bundle9.putBundle("extras", bundle11);
                bundle9.putParcelableArray("remoteInputs", null);
                bundle9.putBoolean("showsUserInterface", lVar2.f6220d);
                bundle9.putInt("semanticAction", 0);
                bundle8.putBundle(string, bundle9);
            }
            bundle6.putBundle("invisible_actions", bundle8);
            bundle7.putBundle("invisible_actions", bundle8);
            if (this.f6234m == null) {
                this.f6234m = new Bundle();
            }
            this.f6234m.putBundle("android.car.EXTENSIONS", bundle6);
            bundle2.putBundle("android.car.EXTENSIONS", bundle7);
        }
        int i9 = Build.VERSION.SDK_INT;
        builderA.setExtras(this.f6234m);
        q.e(builderA, null);
        if (i9 >= 26) {
            r.b(builderA, 0);
            r.e(builderA, null);
            r.f(builderA, null);
            r.g(builderA, 0L);
            r.d(builderA, 0);
            if (!TextUtils.isEmpty(this.f6235n)) {
                builderA.setSound(null).setDefaults(0).setLights(0, 0, 0).setVibrate(null);
            }
        }
        if (i9 >= 28) {
            Iterator it3 = arrayList3.iterator();
            if (it3.hasNext()) {
                it3.next().getClass();
                throw new ClassCastException();
            }
        }
        if (i9 >= 29) {
            t.a(builderA, this.f6236o);
            charSequence = null;
            t.b(builderA, null);
        } else {
            charSequence = null;
        }
        com.google.android.gms.common.internal.r rVar = this.f6231j;
        if (rVar != null) {
            new Notification.BigTextStyle(builderA).setBigContentTitle(charSequence).bigText((CharSequence) rVar.f3598c);
        }
        Notification notificationBuild = Build.VERSION.SDK_INT >= 26 ? builderA.build() : builderA.build();
        if (rVar != null) {
            this.f6231j.getClass();
        }
        if (rVar != null && (bundle = notificationBuild.extras) != null) {
            bundle.putString("androidx.core.app.extra.COMPAT_TEMPLATE", "androidx.core.app.NotificationCompat$BigTextStyle");
        }
        return notificationBuild;
    }

    public final void c(com.google.android.gms.common.internal.r rVar) {
        if (this.f6231j != rVar) {
            this.f6231j = rVar;
            if (((m) rVar.f3597b) != this) {
                rVar.f3597b = this;
                c(rVar);
            }
        }
    }
}
