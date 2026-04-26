package com.google.crypto.tink.shaded.protobuf;

import androidx.datastore.preferences.protobuf.C0199j;

/* JADX INFO: loaded from: classes.dex */
public final class U implements c0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0296a f3761a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final g0 f3762b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0310o f3763c;

    public U(g0 g0Var, C0310o c0310o, AbstractC0296a abstractC0296a) {
        this.f3762b = g0Var;
        c0310o.getClass();
        this.f3763c = c0310o;
        this.f3761a = abstractC0296a;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final boolean a(Object obj) {
        this.f3763c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final void b(Object obj, Object obj2) {
        d0.x(this.f3762b, obj, obj2);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final Object c() {
        AbstractC0296a abstractC0296a = this.f3761a;
        return abstractC0296a instanceof AbstractC0316v ? ((AbstractC0316v) abstractC0296a).q() : abstractC0296a.d().c();
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final void d(Object obj) {
        this.f3762b.getClass();
        ((AbstractC0316v) obj).unknownFields.e = false;
        this.f3763c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final int e(AbstractC0316v abstractC0316v) {
        this.f3762b.getClass();
        f0 f0Var = abstractC0316v.unknownFields;
        int i4 = f0Var.f3789d;
        if (i4 != -1) {
            return i4;
        }
        int iO0 = 0;
        for (int i5 = 0; i5 < f0Var.f3786a; i5++) {
            int i6 = f0Var.f3787b[i5] >>> 3;
            iO0 += C0306k.o0(3, (AbstractC0303h) f0Var.f3788c[i5]) + C0306k.w0(i6) + C0306k.v0(2) + (C0306k.v0(1) * 2);
        }
        f0Var.f3789d = iO0;
        return iO0;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final boolean f(AbstractC0316v abstractC0316v, AbstractC0316v abstractC0316v2) {
        this.f3762b.getClass();
        return abstractC0316v.unknownFields.equals(abstractC0316v2.unknownFields);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final void g(Object obj, byte[] bArr, int i4, int i5, U1.c cVar) {
        AbstractC0316v abstractC0316v = (AbstractC0316v) obj;
        if (abstractC0316v.unknownFields == f0.f3785f) {
            abstractC0316v.unknownFields = f0.c();
        }
        obj.getClass();
        throw new ClassCastException();
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final void h(Object obj, K k4) {
        this.f3763c.getClass();
        B1.a.p(obj);
        throw null;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final int i(AbstractC0316v abstractC0316v) {
        this.f3762b.getClass();
        return abstractC0316v.unknownFields.hashCode();
    }

    @Override // com.google.crypto.tink.shaded.protobuf.c0
    public final void j(Object obj, C0199j c0199j, C0309n c0309n) {
        this.f3762b.getClass();
        g0.a(obj);
        this.f3763c.getClass();
        obj.getClass();
        throw new ClassCastException();
    }
}
