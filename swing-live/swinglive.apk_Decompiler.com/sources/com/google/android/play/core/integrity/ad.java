package com.google.android.play.core.integrity;

import Q0.A;
import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcelable;
import android.util.Base64;
import android.util.Log;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
final class ad {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final Q0.c f3645a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Q0.v f3646b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final String f3647c;

    public ad(Context context, Q0.v vVar) {
        this.f3647c = context.getPackageName();
        this.f3646b = vVar;
        if (Q0.e.a(context)) {
            this.f3645a = new Q0.c(context, vVar, "IntegrityService", ae.f3648a, new A() { // from class: com.google.android.play.core.integrity.aa
                @Override // Q0.A
                public final Object a(IBinder iBinder) {
                    int i4 = Q0.r.f1537d;
                    if (iBinder == null) {
                        return null;
                    }
                    IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.play.core.integrity.protocol.IIntegrityService");
                    return iInterfaceQueryLocalInterface instanceof Q0.s ? (Q0.s) iInterfaceQueryLocalInterface : new Q0.q(iBinder, "com.google.android.play.core.integrity.protocol.IIntegrityService");
                }
            });
            return;
        }
        Object[] objArr = new Object[0];
        vVar.getClass();
        if (Log.isLoggable("PlayCore", 6)) {
            Log.e("PlayCore", Q0.v.c(vVar.f1538a, "Phonesky is not installed.", objArr));
        }
        this.f3645a = null;
    }

    public static Bundle a(ad adVar, byte[] bArr, Long l2, Parcelable parcelable) {
        Bundle bundle = new Bundle();
        bundle.putString("package.name", adVar.f3647c);
        bundle.putByteArray("nonce", bArr);
        bundle.putInt("playcore.integrity.version.major", 1);
        bundle.putInt("playcore.integrity.version.minor", 2);
        bundle.putInt("playcore.integrity.version.patch", 0);
        if (l2 != null) {
            bundle.putLong("cloud.prj", l2.longValue());
        }
        ArrayList arrayList = new ArrayList();
        arrayList.add(new Q0.k(3, System.currentTimeMillis()));
        bundle.putParcelableArrayList("event_timestamps", new ArrayList<>(H0.a.a(arrayList)));
        return bundle;
    }

    public final Task b(IntegrityTokenRequest integrityTokenRequest) {
        if (this.f3645a == null) {
            return Tasks.forException(new IntegrityServiceException(-2, null));
        }
        try {
            byte[] bArrDecode = Base64.decode(integrityTokenRequest.nonce(), 10);
            Long lCloudProjectNumber = integrityTokenRequest.cloudProjectNumber();
            integrityTokenRequest.a();
            this.f3646b.b("requestIntegrityToken(%s)", integrityTokenRequest);
            TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
            Q0.c cVar = this.f3645a;
            ab abVar = new ab(this, taskCompletionSource, bArrDecode, lCloudProjectNumber, null, taskCompletionSource, integrityTokenRequest);
            cVar.getClass();
            cVar.a().post(new Q0.y(cVar, abVar.c(), taskCompletionSource, abVar));
            return taskCompletionSource.getTask();
        } catch (IllegalArgumentException e) {
            return Tasks.forException(new IntegrityServiceException(-13, e));
        }
    }
}
