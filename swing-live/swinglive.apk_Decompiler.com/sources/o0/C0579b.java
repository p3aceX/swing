package o0;

import D2.AbstractActivityC0029d;
import N2.g;
import O2.o;
import O2.p;
import android.app.AlarmManager;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;
import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: renamed from: o0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0579b implements o, p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5960a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public g f5961b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public AbstractActivityC0029d f5962c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5963d;
    public HashMap e;

    public C0579b(Context context) {
        this.f5960a = context;
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // O2.o
    public final boolean a(int i4, int i5, Intent intent) {
        int i6;
        int iCanScheduleExactAlarms;
        AbstractActivityC0029d abstractActivityC0029d = this.f5962c;
        boolean z4 = false;
        z4 = false;
        if (abstractActivityC0029d != null) {
            if (this.e == null) {
                this.f5963d = 0;
                return false;
            }
            if (i4 == 209) {
                Context context = this.f5960a;
                String packageName = context.getPackageName();
                PowerManager powerManager = (PowerManager) context.getSystemService("power");
                if (powerManager != null && powerManager.isIgnoringBatteryOptimizations(packageName)) {
                    z4 = true;
                }
                i6 = 16;
                iCanScheduleExactAlarms = z4;
            } else if (i4 == 210) {
                if (Build.VERSION.SDK_INT >= 30) {
                    i6 = 22;
                    iCanScheduleExactAlarms = Environment.isExternalStorageManager();
                }
            } else if (i4 == 211) {
                i6 = 23;
                iCanScheduleExactAlarms = Settings.canDrawOverlays(abstractActivityC0029d);
            } else if (i4 == 212) {
                if (Build.VERSION.SDK_INT >= 26) {
                    i6 = 24;
                    iCanScheduleExactAlarms = abstractActivityC0029d.getPackageManager().canRequestPackageInstalls();
                }
            } else if (i4 == 213) {
                i6 = 27;
                iCanScheduleExactAlarms = ((NotificationManager) abstractActivityC0029d.getSystemService("notification")).isNotificationPolicyAccessGranted();
            } else if (i4 == 214) {
                i6 = 34;
                iCanScheduleExactAlarms = Build.VERSION.SDK_INT >= 31 ? ((AlarmManager) abstractActivityC0029d.getSystemService("alarm")).canScheduleExactAlarms() : true;
            }
            this.e.put(Integer.valueOf(i6), Integer.valueOf(iCanScheduleExactAlarms));
            int i7 = this.f5963d - 1;
            this.f5963d = i7;
            g gVar = this.f5961b;
            if (gVar != null && i7 == 0) {
                gVar.f1162a.c(this.e);
            }
            return true;
        }
        return false;
    }

    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    /* JADX WARN: Removed duplicated region for block: B:27:0x00a5  */
    @Override // O2.p
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean b(int r24, java.lang.String[] r25, int[] r26) {
        /*
            Method dump skipped, instruction units count: 1376
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o0.C0579b.b(int, java.lang.String[], int[]):boolean");
    }

    /* JADX WARN: Code restructure failed: missing block: B:7:0x0021, code lost:
    
        if (q.v.a(new q.w(r6).f6239a) != false) goto L8;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int c(int r18) {
        /*
            Method dump skipped, instruction units count: 485
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o0.C0579b.c(int):int");
    }

    public final boolean d() {
        ArrayList arrayListV = AbstractC0367g.v(this.f5960a, 37);
        boolean z4 = arrayListV != null && arrayListV.contains("android.permission.WRITE_CALENDAR");
        boolean z5 = arrayListV != null && arrayListV.contains("android.permission.READ_CALENDAR");
        if (z4 && z5) {
            return true;
        }
        if (!z4) {
            Log.d("permissions_handler", "android.permission.WRITE_CALENDAR missing in manifest");
        }
        if (!z5) {
            Log.d("permissions_handler", "android.permission.READ_CALENDAR missing in manifest");
        }
        return false;
    }

    public final void e(int i4, String str) {
        if (this.f5962c == null) {
            return;
        }
        Intent intent = new Intent(str);
        if (!str.equals("android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS")) {
            intent.setData(Uri.parse("package:" + this.f5962c.getPackageName()));
        }
        this.f5962c.startActivityForResult(intent, i4);
        this.f5963d++;
    }
}
