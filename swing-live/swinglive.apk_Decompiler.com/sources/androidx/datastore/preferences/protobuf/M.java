package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class M implements U {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0209u f2922a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final c0 f2923b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0203n f2924c;

    public M(c0 c0Var, C0203n c0203n, AbstractC0209u abstractC0209u) {
        this.f2923b = c0Var;
        c0203n.getClass();
        this.f2924c = c0203n;
        this.f2922a = abstractC0209u;
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final boolean a(Object obj) {
        this.f2924c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final void b(Object obj, Object obj2) {
        V.k(this.f2923b, obj, obj2);
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final AbstractC0209u c() {
        AbstractC0209u abstractC0209u = this.f2922a;
        return abstractC0209u != null ? abstractC0209u.i() : ((AbstractC0207s) abstractC0209u.c(5)).b();
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final void d(Object obj) {
        this.f2923b.getClass();
        b0 b0Var = ((AbstractC0209u) obj).unknownFields;
        if (b0Var.e) {
            b0Var.e = false;
        }
        this.f2924c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final boolean e(AbstractC0209u abstractC0209u, AbstractC0209u abstractC0209u2) {
        this.f2923b.getClass();
        return abstractC0209u.unknownFields.equals(abstractC0209u2.unknownFields);
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final void f(Object obj, C0199j c0199j, C0202m c0202m) {
        this.f2923b.getClass();
        c0.a(obj);
        this.f2924c.getClass();
        obj.getClass();
        throw new ClassCastException();
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final void g(Object obj, D d5) {
        this.f2924c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final int h(AbstractC0209u abstractC0209u) {
        this.f2923b.getClass();
        return abstractC0209u.unknownFields.hashCode();
    }

    @Override // androidx.datastore.preferences.protobuf.U
    public final int i(AbstractC0209u abstractC0209u) {
        this.f2923b.getClass();
        b0 b0Var = abstractC0209u.unknownFields;
        int i4 = b0Var.f2958d;
        if (i4 != -1) {
            return i4;
        }
        int iT0 = 0;
        for (int i5 = 0; i5 < b0Var.f2955a; i5++) {
            int i6 = b0Var.f2956b[i5] >>> 3;
            iT0 += C0200k.t0(3, (C0196g) b0Var.f2957c[i5]) + C0200k.w0(i6) + C0200k.v0(2) + (C0200k.v0(1) * 2);
        }
        b0Var.f2958d = iT0;
        return iT0;
    }
}
