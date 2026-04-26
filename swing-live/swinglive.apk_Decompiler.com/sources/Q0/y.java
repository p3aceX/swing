package Q0;

import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
public final class y extends w {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ TaskCompletionSource f1541m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ w f1542n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ c f1543o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public y(c cVar, TaskCompletionSource taskCompletionSource, TaskCompletionSource taskCompletionSource2, w wVar) {
        super(taskCompletionSource);
        this.f1543o = cVar;
        this.f1541m = taskCompletionSource2;
        this.f1542n = wVar;
    }

    @Override // Q0.w
    public final void b() {
        synchronized (this.f1543o.f1520f) {
            try {
                c cVar = this.f1543o;
                TaskCompletionSource taskCompletionSource = this.f1541m;
                cVar.e.add(taskCompletionSource);
                taskCompletionSource.getTask().addOnCompleteListener(new D2.v(cVar, taskCompletionSource, 17, false));
                if (this.f1543o.f1526l.getAndIncrement() > 0) {
                    this.f1543o.f1517b.b("Already connected to the service.", new Object[0]);
                }
                c.b(this.f1543o, this.f1542n);
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
