package com.google.android.gms.common.api.internal;

import android.os.SystemClock;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.AbstractC0283f;
import com.google.android.gms.common.internal.C0286i;
import com.google.android.gms.common.internal.C0294q;
import com.google.android.gms.internal.base.zaq;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class L implements OnCompleteListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0259g f3415a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3416b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0253a f3417c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final long f3418d;
    public final long e;

    public L(C0259g c0259g, int i4, C0253a c0253a, long j4, long j5) {
        this.f3415a = c0259g;
        this.f3416b = i4;
        this.f3417c = c0253a;
        this.f3418d = j4;
        this.e = j5;
    }

    public static C0286i a(E e, AbstractC0283f abstractC0283f, int i4) {
        C0286i telemetryConfiguration = abstractC0283f.getTelemetryConfiguration();
        if (telemetryConfiguration != null && telemetryConfiguration.f3564b) {
            int i5 = 0;
            int[] iArr = telemetryConfiguration.f3566d;
            if (iArr == null) {
                int[] iArr2 = telemetryConfiguration.f3567f;
                if (iArr2 != null) {
                    while (i5 < iArr2.length) {
                        if (iArr2[i5] == i4) {
                            return null;
                        }
                        i5++;
                    }
                }
            } else {
                while (i5 < iArr.length) {
                    if (iArr[i5] != i4) {
                        i5++;
                    }
                }
            }
            if (e.f3403l < telemetryConfiguration.e) {
                return telemetryConfiguration;
            }
        }
        return null;
    }

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public final void onComplete(Task task) {
        E e;
        int i4;
        int i5;
        int i6;
        int i7;
        long j4;
        long j5;
        C0259g c0259g = this.f3415a;
        if (c0259g.c()) {
            com.google.android.gms.common.internal.u uVar = (com.google.android.gms.common.internal.u) com.google.android.gms.common.internal.t.b().f3601a;
            if ((uVar == null || uVar.f3603b) && (e = (E) c0259g.f3477j.get(this.f3417c)) != null) {
                Object obj = e.f3394b;
                if (obj instanceof AbstractC0283f) {
                    AbstractC0283f abstractC0283f = (AbstractC0283f) obj;
                    long j6 = this.f3418d;
                    int i8 = 0;
                    boolean z4 = j6 > 0;
                    int gCoreServiceId = abstractC0283f.getGCoreServiceId();
                    if (uVar != null) {
                        z4 &= uVar.f3604c;
                        boolean zHasConnectionInfo = abstractC0283f.hasConnectionInfo();
                        i4 = uVar.f3605d;
                        int i9 = uVar.f3602a;
                        if (!zHasConnectionInfo || abstractC0283f.isConnecting()) {
                            i6 = uVar.e;
                            i5 = i9;
                        } else {
                            C0286i c0286iA = a(e, abstractC0283f, this.f3416b);
                            if (c0286iA == null) {
                                return;
                            }
                            boolean z5 = c0286iA.f3565c && j6 > 0;
                            i6 = c0286iA.e;
                            i5 = i9;
                            z4 = z5;
                        }
                    } else {
                        i4 = 5000;
                        i5 = 0;
                        i6 = 100;
                    }
                    int i10 = i4;
                    int iElapsedRealtime = -1;
                    if (task.isSuccessful()) {
                        i7 = 0;
                    } else if (task.isCanceled()) {
                        i8 = -1;
                        i7 = 100;
                    } else {
                        Exception exception = task.getException();
                        if (exception instanceof com.google.android.gms.common.api.j) {
                            Status status = ((com.google.android.gms.common.api.j) exception).getStatus();
                            int i11 = status.f3378b;
                            C0771b c0771b = status.e;
                            i7 = i11;
                            i8 = c0771b == null ? -1 : c0771b.f6949b;
                        } else {
                            i7 = 101;
                            i8 = -1;
                        }
                    }
                    if (z4) {
                        long jCurrentTimeMillis = System.currentTimeMillis();
                        iElapsedRealtime = (int) (SystemClock.elapsedRealtime() - this.e);
                        j4 = j6;
                        j5 = jCurrentTimeMillis;
                    } else {
                        j4 = 0;
                        j5 = 0;
                    }
                    int i12 = iElapsedRealtime;
                    zaq zaqVar = c0259g.f3481n;
                    zaqVar.sendMessage(zaqVar.obtainMessage(18, new M(new C0294q(this.f3416b, i7, i8, j4, j5, null, null, gCoreServiceId, i12), i5, i10, i6)));
                }
            }
        }
    }
}
