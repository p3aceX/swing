package Q3;

import java.util.concurrent.ScheduledFuture;

/* JADX INFO: renamed from: Q3.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0133i implements InterfaceC0135j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1631a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f1632b;

    public /* synthetic */ C0133i(Object obj, int i4) {
        this.f1631a = i4;
        this.f1632b = obj;
    }

    @Override // Q3.InterfaceC0135j
    public final void a(Throwable th) {
        switch (this.f1631a) {
            case 0:
                ((ScheduledFuture) this.f1632b).cancel(false);
                break;
            case 1:
                ((I3.l) this.f1632b).invoke(th);
                break;
            default:
                ((Q) this.f1632b).a();
                break;
        }
    }

    public final String toString() {
        switch (this.f1631a) {
            case 0:
                return "CancelFutureOnCancel[" + ((ScheduledFuture) this.f1632b) + ']';
            case 1:
                return "CancelHandler.UserSupplied[" + ((I3.l) this.f1632b).getClass().getSimpleName() + '@' + F.l(this) + ']';
            default:
                return "DisposeOnCancel[" + ((Q) this.f1632b) + ']';
        }
    }
}
