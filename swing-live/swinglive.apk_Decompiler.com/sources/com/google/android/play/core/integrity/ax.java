package com.google.android.play.core.integrity;

import Q0.A;
import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
final class ax {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final Q0.c f3676a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Q0.v f3677b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final String f3678c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    private final TaskCompletionSource f3679d;

    public ax(Context context, Q0.v vVar) {
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        this.f3679d = taskCompletionSource;
        this.f3678c = context.getPackageName();
        this.f3677b = vVar;
        Q0.c cVar = new Q0.c(context, vVar, "ExpressIntegrityService", ay.f3680a, new A() { // from class: com.google.android.play.core.integrity.ap
            @Override // Q0.A
            public final Object a(IBinder iBinder) {
                int i4 = Q0.m.f1536d;
                if (iBinder == null) {
                    return null;
                }
                IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.play.core.integrity.protocol.IExpressIntegrityService");
                return iInterfaceQueryLocalInterface instanceof Q0.n ? (Q0.n) iInterfaceQueryLocalInterface : new Q0.l(iBinder, "com.google.android.play.core.integrity.protocol.IExpressIntegrityService");
            }
        });
        this.f3676a = cVar;
        cVar.a().post(new aq(this, taskCompletionSource, context));
    }

    public static Bundle a(ax axVar, String str, long j4, long j5) {
        Bundle bundle = new Bundle();
        bundle.putString("package.name", axVar.f3678c);
        bundle.putLong("cloud.prj", j4);
        bundle.putString("nonce", str);
        bundle.putLong("warm.up.sid", j5);
        ArrayList arrayList = new ArrayList();
        arrayList.add(new Q0.k(5, System.currentTimeMillis()));
        bundle.putParcelableArrayList("event_timestamps", new ArrayList<>(H0.a.a(arrayList)));
        return bundle;
    }

    public static Bundle b(ax axVar, long j4) {
        Bundle bundle = new Bundle();
        bundle.putString("package.name", axVar.f3678c);
        bundle.putLong("cloud.prj", j4);
        ArrayList arrayList = new ArrayList();
        arrayList.add(new Q0.k(4, System.currentTimeMillis()));
        bundle.putParcelableArrayList("event_timestamps", new ArrayList<>(H0.a.a(arrayList)));
        return bundle;
    }

    public static /* bridge */ /* synthetic */ boolean g(ax axVar) {
        return axVar.f3679d.getTask().isSuccessful() && !((Boolean) axVar.f3679d.getTask().getResult()).booleanValue();
    }

    public final Task c(String str, long j4, long j5) {
        this.f3677b.b("requestExpressIntegrityToken(%s)", Long.valueOf(j5));
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        Q0.c cVar = this.f3676a;
        as asVar = new as(this, taskCompletionSource, str, j4, j5, taskCompletionSource);
        cVar.getClass();
        cVar.a().post(new Q0.y(cVar, asVar.c(), taskCompletionSource, asVar));
        return taskCompletionSource.getTask();
    }

    public final Task d(long j4) {
        this.f3677b.b("warmUpIntegrityToken(%s)", Long.valueOf(j4));
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        Q0.c cVar = this.f3676a;
        ar arVar = new ar(this, taskCompletionSource, j4, taskCompletionSource);
        cVar.getClass();
        cVar.a().post(new Q0.y(cVar, arVar.c(), taskCompletionSource, arVar));
        return taskCompletionSource.getTask();
    }
}
