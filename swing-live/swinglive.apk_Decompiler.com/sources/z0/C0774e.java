package z0;

import O.AbstractActivityC0114z;
import O.C0090a;
import O.C0113y;
import O.N;
import android.R;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Build;
import android.util.Log;
import android.util.TypedValue;
import com.google.android.gms.common.api.GoogleApiActivity;
import com.google.android.gms.common.api.internal.InterfaceC0263k;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import com.google.android.gms.common.internal.x;
import com.google.android.gms.common.internal.y;
import com.google.crypto.tink.shaded.protobuf.S;
import k.AbstractC0501s;

/* JADX INFO: renamed from: z0.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0774e extends C0775f {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Object f6958c = new Object();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0774e f6959d = new C0774e();

    public static AlertDialog e(Activity activity, int i4, y yVar, DialogInterface.OnCancelListener onCancelListener) {
        if (i4 == 0) {
            return null;
        }
        TypedValue typedValue = new TypedValue();
        activity.getTheme().resolveAttribute(R.attr.alertDialogTheme, typedValue, true);
        AlertDialog.Builder builder = "Theme.Dialog.Alert".equals(activity.getResources().getResourceEntryName(typedValue.resourceId)) ? new AlertDialog.Builder(activity, 5) : null;
        if (builder == null) {
            builder = new AlertDialog.Builder(activity);
        }
        builder.setMessage(x.b(activity, i4));
        if (onCancelListener != null) {
            builder.setOnCancelListener(onCancelListener);
        }
        Resources resources = activity.getResources();
        String string = i4 != 1 ? i4 != 2 ? i4 != 3 ? resources.getString(R.string.ok) : resources.getString(com.swing.live.R.string.common_google_play_services_enable_button) : resources.getString(com.swing.live.R.string.common_google_play_services_update_button) : resources.getString(com.swing.live.R.string.common_google_play_services_install_button);
        if (string != null) {
            builder.setPositiveButton(string, yVar);
        }
        String strC = x.c(activity, i4);
        if (strC != null) {
            builder.setTitle(strC);
        }
        Log.w("GoogleApiAvailability", S.d(i4, "Creating dialog for Google Play services availability issue. ConnectionResult="), new IllegalArgumentException());
        return builder.create();
    }

    public static void f(Activity activity, AlertDialog alertDialog, String str, DialogInterface.OnCancelListener onCancelListener) {
        try {
            if (activity instanceof AbstractActivityC0114z) {
                C0113y c0113y = (C0113y) ((AbstractActivityC0114z) activity).f1438x.f104b;
                C0780k c0780k = new C0780k();
                F.h(alertDialog, "Cannot display null dialog");
                alertDialog.setOnCancelListener(null);
                alertDialog.setOnDismissListener(null);
                c0780k.f6970m0 = alertDialog;
                if (onCancelListener != null) {
                    c0780k.n0 = onCancelListener;
                }
                c0780k.f1371j0 = false;
                c0780k.f1372k0 = true;
                N n4 = c0113y.e;
                n4.getClass();
                C0090a c0090a = new C0090a(n4);
                c0090a.f1317o = true;
                c0090a.e(0, c0780k, str);
                c0090a.d(false);
                return;
            }
        } catch (NoClassDefFoundError unused) {
        }
        FragmentManager fragmentManager = activity.getFragmentManager();
        DialogFragmentC0772c dialogFragmentC0772c = new DialogFragmentC0772c();
        F.h(alertDialog, "Cannot display null dialog");
        alertDialog.setOnCancelListener(null);
        alertDialog.setOnDismissListener(null);
        dialogFragmentC0772c.f6952a = alertDialog;
        if (onCancelListener != null) {
            dialogFragmentC0772c.f6953b = onCancelListener;
        }
        dialogFragmentC0772c.show(fragmentManager, str);
    }

    @Override // z0.C0775f
    public final int b(Context context) {
        return c(context, C0775f.f6960a);
    }

    public final void d(GoogleApiActivity googleApiActivity, int i4, GoogleApiActivity googleApiActivity2) {
        AlertDialog alertDialogE = e(googleApiActivity, i4, new y(super.a(googleApiActivity, i4, "d"), googleApiActivity, 0), googleApiActivity2);
        if (alertDialogE == null) {
            return;
        }
        f(googleApiActivity, alertDialogE, "GooglePlayServicesErrorDialog", googleApiActivity2);
    }

    public final void g(Context context, int i4, PendingIntent pendingIntent) {
        int i5;
        Log.w("GoogleApiAvailability", B1.a.l("GMS core API Availability. ConnectionResult=", i4, ", tag=null"), new IllegalArgumentException());
        if (i4 == 18) {
            new HandlerC0781l(this, context).sendEmptyMessageDelayed(1, 120000L);
            return;
        }
        if (pendingIntent == null) {
            if (i4 == 6) {
                Log.w("GoogleApiAvailability", "Missing resolution for ConnectionResult.RESOLUTION_REQUIRED. Call GoogleApiAvailability#showErrorNotification(Context, ConnectionResult) instead.");
                return;
            }
            return;
        }
        String strE = i4 == 6 ? x.e(context, "common_google_play_services_resolution_required_title") : x.c(context, i4);
        if (strE == null) {
            strE = context.getResources().getString(com.swing.live.R.string.common_google_play_services_notification_ticker);
        }
        String strD = (i4 == 6 || i4 == 19) ? x.d(context, "common_google_play_services_resolution_required_text", x.a(context)) : x.b(context, i4);
        Resources resources = context.getResources();
        Object systemService = context.getSystemService("notification");
        F.g(systemService);
        NotificationManager notificationManager = (NotificationManager) systemService;
        q.m mVar = new q.m(context, null);
        mVar.f6232k = true;
        mVar.f6237p.flags |= 16;
        mVar.e = q.m.b(strE);
        r rVar = new r(18, false);
        rVar.f3598c = q.m.b(strD);
        mVar.c(rVar);
        PackageManager packageManager = context.getPackageManager();
        if (G0.a.f485b == null) {
            G0.a.f485b = Boolean.valueOf(packageManager.hasSystemFeature("android.hardware.type.watch"));
        }
        if (G0.a.f485b.booleanValue()) {
            mVar.f6237p.icon = context.getApplicationInfo().icon;
            mVar.f6229h = 2;
            if (G0.a.e(context)) {
                mVar.f6224b.add(new q.l(resources.getString(com.swing.live.R.string.common_open_on_phone), pendingIntent));
            } else {
                mVar.f6228g = pendingIntent;
            }
        } else {
            mVar.f6237p.icon = R.drawable.stat_sys_warning;
            mVar.f6237p.tickerText = q.m.b(resources.getString(com.swing.live.R.string.common_google_play_services_notification_ticker));
            mVar.f6237p.when = System.currentTimeMillis();
            mVar.f6228g = pendingIntent;
            mVar.f6227f = q.m.b(strD);
        }
        int i6 = Build.VERSION.SDK_INT;
        if (i6 >= 26) {
            if (i6 < 26) {
                throw new IllegalStateException();
            }
            synchronized (f6958c) {
            }
            NotificationChannel notificationChannel = notificationManager.getNotificationChannel("com.google.android.gms.availability");
            String string = context.getResources().getString(com.swing.live.R.string.common_google_play_services_notification_channel_name);
            if (notificationChannel == null) {
                notificationManager.createNotificationChannel(AbstractC0501s.d(string));
            } else if (!string.contentEquals(notificationChannel.getName())) {
                notificationChannel.setName(string);
                notificationManager.createNotificationChannel(notificationChannel);
            }
            mVar.f6235n = "com.google.android.gms.availability";
        }
        Notification notificationA = mVar.a();
        if (i4 == 1 || i4 == 2 || i4 == 3) {
            AbstractC0778i.f6963a.set(false);
            i5 = 10436;
        } else {
            i5 = 39789;
        }
        notificationManager.notify(i5, notificationA);
    }

    public final void h(Activity activity, InterfaceC0263k interfaceC0263k, int i4, DialogInterface.OnCancelListener onCancelListener) {
        AlertDialog alertDialogE = e(activity, i4, new y(super.a(activity, i4, "d"), interfaceC0263k, 1), onCancelListener);
        if (alertDialogE == null) {
            return;
        }
        f(activity, alertDialogE, "GooglePlayServicesErrorDialog", onCancelListener);
    }
}
