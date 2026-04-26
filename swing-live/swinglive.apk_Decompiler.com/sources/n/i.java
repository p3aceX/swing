package n;

import java.util.Iterator;
import java.util.Map;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
public final class i implements Iterator, Map.Entry {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5846a;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Y0.d f5849d;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f5848c = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5847b = -1;

    public i(Y0.d dVar) {
        this.f5849d = dVar;
        this.f5846a = dVar.d() - 1;
    }

    @Override // java.util.Map.Entry
    public final boolean equals(Object obj) {
        if (!this.f5848c) {
            throw new IllegalStateException("This container does not support retaining Map.Entry objects");
        }
        if (!(obj instanceof Map.Entry)) {
            return false;
        }
        Map.Entry entry = (Map.Entry) obj;
        Object key = entry.getKey();
        int i4 = this.f5847b;
        Y0.d dVar = this.f5849d;
        Object objB = dVar.b(i4, 0);
        if (key != objB && (key == null || !key.equals(objB))) {
            return false;
        }
        Object value = entry.getValue();
        Object objB2 = dVar.b(this.f5847b, 1);
        return value == objB2 || (value != null && value.equals(objB2));
    }

    @Override // java.util.Map.Entry
    public final Object getKey() {
        if (!this.f5848c) {
            throw new IllegalStateException("This container does not support retaining Map.Entry objects");
        }
        return this.f5849d.b(this.f5847b, 0);
    }

    @Override // java.util.Map.Entry
    public final Object getValue() {
        if (!this.f5848c) {
            throw new IllegalStateException("This container does not support retaining Map.Entry objects");
        }
        return this.f5849d.b(this.f5847b, 1);
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f5847b < this.f5846a;
    }

    @Override // java.util.Map.Entry
    public final int hashCode() {
        if (!this.f5848c) {
            throw new IllegalStateException("This container does not support retaining Map.Entry objects");
        }
        int i4 = this.f5847b;
        Y0.d dVar = this.f5849d;
        Object objB = dVar.b(i4, 0);
        Object objB2 = dVar.b(this.f5847b, 1);
        return (objB == null ? 0 : objB.hashCode()) ^ (objB2 != null ? objB2.hashCode() : 0);
    }

    @Override // java.util.Iterator
    public final Object next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        this.f5847b++;
        this.f5848c = true;
        return this;
    }

    @Override // java.util.Iterator
    public final void remove() {
        if (!this.f5848c) {
            throw new IllegalStateException();
        }
        this.f5849d.h(this.f5847b);
        this.f5847b--;
        this.f5846a--;
        this.f5848c = false;
    }

    @Override // java.util.Map.Entry
    public final Object setValue(Object obj) {
        if (this.f5848c) {
            return this.f5849d.i(this.f5847b, obj);
        }
        throw new IllegalStateException("This container does not support retaining Map.Entry objects");
    }

    public final String toString() {
        return getKey() + "=" + getValue();
    }
}
