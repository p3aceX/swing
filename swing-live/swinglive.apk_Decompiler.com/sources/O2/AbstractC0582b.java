package o2;

import I3.p;
import J3.i;
import k.C0502t;
import r2.u;

/* JADX INFO: renamed from: o2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0582b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final p2.b f5967a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5968b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0502t f5969c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5970d;

    public AbstractC0582b(int i4, p2.b bVar) {
        i.e(bVar, "psiManager");
        this.f5967a = bVar;
        this.f5968b = i4;
        this.f5969c = new C0502t(bVar);
        this.f5970d = this.f5968b / 188;
    }

    public abstract Object a(B1.d dVar, p pVar, u uVar);

    public abstract void b(boolean z4);
}
