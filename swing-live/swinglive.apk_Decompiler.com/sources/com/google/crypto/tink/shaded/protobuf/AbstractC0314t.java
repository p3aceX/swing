package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0314t implements P, Cloneable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0316v f3837a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0316v f3838b;

    public AbstractC0314t(AbstractC0316v abstractC0316v) {
        this.f3837a = abstractC0316v;
        if (abstractC0316v.n()) {
            throw new IllegalArgumentException("Default instance must be immutable.");
        }
        this.f3838b = abstractC0316v.q();
    }

    public static void f(Object obj, Object obj2) {
        Z z4 = Z.f3766c;
        z4.getClass();
        z4.a(obj.getClass()).b(obj, obj2);
    }

    public final AbstractC0316v b() {
        AbstractC0316v abstractC0316vC = c();
        abstractC0316vC.getClass();
        if (AbstractC0316v.m(abstractC0316vC, true)) {
            return abstractC0316vC;
        }
        throw new e0();
    }

    public final AbstractC0316v c() {
        if (!this.f3838b.n()) {
            return this.f3838b;
        }
        AbstractC0316v abstractC0316v = this.f3838b;
        abstractC0316v.getClass();
        Z z4 = Z.f3766c;
        z4.getClass();
        z4.a(abstractC0316v.getClass()).d(abstractC0316v);
        abstractC0316v.o();
        return this.f3838b;
    }

    public final AbstractC0314t d() {
        AbstractC0314t abstractC0314tP = this.f3837a.d();
        abstractC0314tP.f3838b = c();
        return abstractC0314tP;
    }

    public final void e() {
        if (this.f3838b.n()) {
            return;
        }
        AbstractC0316v abstractC0316vQ = this.f3837a.q();
        f(abstractC0316vQ, this.f3838b);
        this.f3838b = abstractC0316vQ;
    }
}
