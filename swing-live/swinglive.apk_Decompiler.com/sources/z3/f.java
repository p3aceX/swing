package Z3;

import x3.AbstractC0726f;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f2614a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2615b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2616c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public i f2617d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public f f2618f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public f f2619g;

    public f() {
        this.f2614a = new byte[8192];
        this.e = true;
        this.f2617d = null;
    }

    public final int a() {
        return this.f2614a.length - this.f2616c;
    }

    public final int b() {
        return this.f2616c - this.f2615b;
    }

    public final f c() {
        f fVar = this.f2618f;
        f fVar2 = this.f2619g;
        if (fVar2 != null) {
            J3.i.b(fVar2);
            fVar2.f2618f = this.f2618f;
        }
        f fVar3 = this.f2618f;
        if (fVar3 != null) {
            J3.i.b(fVar3);
            fVar3.f2619g = this.f2619g;
        }
        this.f2618f = null;
        this.f2619g = null;
        return fVar;
    }

    public final void d(f fVar) {
        J3.i.e(fVar, "segment");
        fVar.f2619g = this;
        fVar.f2618f = this.f2618f;
        f fVar2 = this.f2618f;
        if (fVar2 != null) {
            fVar2.f2619g = fVar;
        }
        this.f2618f = fVar;
    }

    public final f e() {
        i eVar = this.f2617d;
        if (eVar == null) {
            f fVar = g.f2620a;
            eVar = new e();
            this.f2617d = eVar;
        }
        int i4 = this.f2615b;
        int i5 = this.f2616c;
        e.f2612c.incrementAndGet((e) eVar);
        return new f(this.f2614a, i4, i5, eVar);
    }

    public final void f(f fVar, int i4) {
        J3.i.e(fVar, "sink");
        if (!fVar.e) {
            throw new IllegalStateException("only owner can write");
        }
        if (fVar.f2616c + i4 > 8192) {
            i iVar = fVar.f2617d;
            if (iVar != null && ((e) iVar).f2613b > 0) {
                throw new IllegalArgumentException();
            }
            int i5 = fVar.f2616c;
            int i6 = fVar.f2615b;
            if ((i5 + i4) - i6 > 8192) {
                throw new IllegalArgumentException();
            }
            byte[] bArr = fVar.f2614a;
            AbstractC0726f.d0(bArr, 0, bArr, i6, i5);
            fVar.f2616c -= fVar.f2615b;
            fVar.f2615b = 0;
        }
        int i7 = fVar.f2616c;
        int i8 = this.f2615b;
        AbstractC0726f.d0(this.f2614a, i7, fVar.f2614a, i8, i8 + i4);
        fVar.f2616c += i4;
        this.f2615b += i4;
    }

    public f(byte[] bArr, int i4, int i5, i iVar) {
        this.f2614a = bArr;
        this.f2615b = i4;
        this.f2616c = i5;
        this.f2617d = iVar;
        this.e = false;
    }
}
