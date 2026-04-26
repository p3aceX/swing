package b;

import O.AbstractActivityC0114z;
import e2.Q;
import java.util.concurrent.PriorityBlockingQueue;
import m1.C0553h;
import r2.x;
import y1.C0754d;

/* JADX INFO: renamed from: b.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0227d implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3209a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f3210b;

    public /* synthetic */ C0227d(Object obj, int i4) {
        this.f3209a = i4;
        this.f3210b = obj;
    }

    @Override // I3.a
    public final Object a() throws InterruptedException {
        switch (this.f3209a) {
            case 0:
                ((AbstractActivityC0114z) this.f3210b).reportFullyDrawn();
                return null;
            case 1:
                Object objTake = ((PriorityBlockingQueue) ((Q) this.f3210b).f79d.f5711a).take();
                J3.i.d(objTake, "take(...)");
                return (B1.d) objTake;
            case 2:
                Object objTake2 = ((PriorityBlockingQueue) ((x) this.f3210b).f79d.f5711a).take();
                J3.i.d(objTake2, "take(...)");
                return (B1.d) objTake2;
            default:
                C0754d c0754d = (C0754d) this.f3210b;
                C0553h c0553h = c0754d.f6842a;
                ((y2.g) c0553h.f5788a).f6897o.set(c0754d.f6844c);
                return w3.i.f6729a;
        }
    }
}
