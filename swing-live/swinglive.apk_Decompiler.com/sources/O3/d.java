package O3;

import A3.i;
import e1.AbstractC0367g;
import java.util.Iterator;
import java.util.NoSuchElementException;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class d implements Iterator, InterfaceC0762c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f1463a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f1464b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public InterfaceC0762c f1465c;

    public final RuntimeException a() {
        int i4 = this.f1463a;
        if (i4 == 4) {
            return new NoSuchElementException();
        }
        if (i4 == 5) {
            return new IllegalStateException("Iterator has failed.");
        }
        return new IllegalStateException("Unexpected state of the iterator: " + this.f1463a);
    }

    public final void b(Object obj, i iVar) {
        this.f1464b = obj;
        this.f1463a = 3;
        this.f1465c = iVar;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return C0768i.f6945a;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        int i4;
        while (true) {
            i4 = this.f1463a;
            if (i4 != 0) {
                break;
            }
            this.f1463a = 5;
            InterfaceC0762c interfaceC0762c = this.f1465c;
            J3.i.b(interfaceC0762c);
            this.f1465c = null;
            interfaceC0762c.resumeWith(w3.i.f6729a);
        }
        if (i4 == 1) {
            J3.i.b(null);
            throw null;
        }
        if (i4 == 2 || i4 == 3) {
            return true;
        }
        if (i4 == 4) {
            return false;
        }
        throw a();
    }

    @Override // java.util.Iterator
    public final Object next() {
        int i4 = this.f1463a;
        if (i4 == 0 || i4 == 1) {
            if (hasNext()) {
                return next();
            }
            throw new NoSuchElementException();
        }
        if (i4 == 2) {
            this.f1463a = 1;
            J3.i.b(null);
            throw null;
        }
        if (i4 != 3) {
            throw a();
        }
        this.f1463a = 0;
        Object obj = this.f1464b;
        this.f1464b = null;
        return obj;
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) {
        AbstractC0367g.M(obj);
        this.f1463a = 4;
    }
}
