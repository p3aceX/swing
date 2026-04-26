package J3;

import java.util.Iterator;
import java.util.NoSuchElementException;
import x3.AbstractC0723c;

/* JADX INFO: loaded from: classes.dex */
public class a implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f813a = 1;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f814b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f815c;

    public a(Object[] objArr) {
        i.e(objArr, "array");
        this.f815c = objArr;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        switch (this.f813a) {
            case 0:
                if (this.f814b < ((Object[]) this.f815c).length) {
                }
                break;
            default:
                if (this.f814b < ((AbstractC0723c) this.f815c).f()) {
                }
                break;
        }
        return false;
    }

    @Override // java.util.Iterator
    public final Object next() {
        switch (this.f813a) {
            case 0:
                try {
                    Object[] objArr = (Object[]) this.f815c;
                    int i4 = this.f814b;
                    this.f814b = i4 + 1;
                    return objArr[i4];
                } catch (ArrayIndexOutOfBoundsException e) {
                    this.f814b--;
                    throw new NoSuchElementException(e.getMessage());
                }
            default:
                if (!hasNext()) {
                    throw new NoSuchElementException();
                }
                int i5 = this.f814b;
                this.f814b = i5 + 1;
                return ((AbstractC0723c) this.f815c).get(i5);
        }
    }

    @Override // java.util.Iterator
    public final void remove() {
        switch (this.f813a) {
            case 0:
                throw new UnsupportedOperationException("Operation is not supported for read-only collection");
            default:
                throw new UnsupportedOperationException("Operation is not supported for read-only collection");
        }
    }

    public a(AbstractC0723c abstractC0723c) {
        this.f815c = abstractC0723c;
    }
}
