package j3;

import T2.t;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import java.util.Objects;

/* JADX INFO: renamed from: j3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0465b implements OnCompleteListener, O2.b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5227a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0466c f5228b;

    public /* synthetic */ C0465b(C0466c c0466c, int i4) {
        this.f5227a = i4;
        this.f5228b = c0466c;
    }

    /* JADX WARN: Removed duplicated region for block: B:91:0x0284  */
    @Override // O2.b
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void d(java.lang.Object r21, D2.v r22) {
        /*
            Method dump skipped, instruction units count: 930
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: j3.C0465b.d(java.lang.Object, D2.v):void");
    }

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public void onComplete(Task task) {
        switch (this.f5227a) {
            case 0:
                C0466c c0466c = this.f5228b;
                c0466c.getClass();
                if (!task.isSuccessful()) {
                    c0466c.c("status", "Failed to signout.");
                } else {
                    t tVar = (t) c0466c.e.f2490c;
                    Objects.requireNonNull(tVar);
                    tVar.c();
                    c0466c.e = null;
                }
                break;
            case 1:
                C0466c c0466c2 = this.f5228b;
                c0466c2.getClass();
                if (!task.isSuccessful()) {
                    c0466c2.c("status", "Failed to disconnect.");
                } else {
                    t tVar2 = (t) c0466c2.e.f2490c;
                    Objects.requireNonNull(tVar2);
                    tVar2.c();
                    c0466c2.e = null;
                }
                break;
            default:
                this.f5228b.h(task);
                break;
        }
    }
}
