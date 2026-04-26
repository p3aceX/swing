package n;

import java.util.Collection;
import java.util.ConcurrentModificationException;
import java.util.Map;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class b extends k implements Map {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public C0557a f5824n;

    public b(int i4) {
        if (i4 == 0) {
            this.f5854a = d.f5834a;
            this.f5855b = d.f5835b;
        } else {
            a(i4);
        }
        this.f5856c = 0;
    }

    @Override // java.util.Map
    public final Set entrySet() {
        if (this.f5824n == null) {
            this.f5824n = new C0557a(this, 0);
        }
        C0557a c0557a = this.f5824n;
        if (((h) c0557a.f2470a) == null) {
            c0557a.f2470a = new h(c0557a, 0);
        }
        return (h) c0557a.f2470a;
    }

    @Override // java.util.Map
    public final Set keySet() {
        if (this.f5824n == null) {
            this.f5824n = new C0557a(this, 0);
        }
        C0557a c0557a = this.f5824n;
        if (((h) c0557a.f2471b) == null) {
            c0557a.f2471b = new h(c0557a, 1);
        }
        return (h) c0557a.f2471b;
    }

    @Override // java.util.Map
    public final void putAll(Map map) {
        int size = map.size() + this.f5856c;
        int i4 = this.f5856c;
        int[] iArr = this.f5854a;
        if (iArr.length < size) {
            Object[] objArr = this.f5855b;
            a(size);
            if (this.f5856c > 0) {
                System.arraycopy(iArr, 0, this.f5854a, 0, i4);
                System.arraycopy(objArr, 0, this.f5855b, 0, i4 << 1);
            }
            k.b(iArr, objArr, i4);
        }
        if (this.f5856c != i4) {
            throw new ConcurrentModificationException();
        }
        for (Map.Entry entry : map.entrySet()) {
            put(entry.getKey(), entry.getValue());
        }
    }

    @Override // java.util.Map
    public final Collection values() {
        if (this.f5824n == null) {
            this.f5824n = new C0557a(this, 0);
        }
        C0557a c0557a = this.f5824n;
        if (((j) c0557a.f2472c) == null) {
            c0557a.f2472c = new j(c0557a);
        }
        return (j) c0557a.f2472c;
    }
}
