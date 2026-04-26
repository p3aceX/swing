package n;

import java.util.Map;

/* JADX INFO: renamed from: n.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0557a extends Y0.d {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ int f5823d;
    public final /* synthetic */ Object e;

    public /* synthetic */ C0557a(Object obj, int i4) {
        this.f5823d = i4;
        this.e = obj;
    }

    @Override // Y0.d
    public final void a() {
        switch (this.f5823d) {
            case 0:
                ((b) this.e).clear();
                break;
            default:
                ((c) this.e).clear();
                break;
        }
    }

    @Override // Y0.d
    public final Object b(int i4, int i5) {
        switch (this.f5823d) {
            case 0:
                return ((b) this.e).f5855b[(i4 << 1) + i5];
            default:
                return ((c) this.e).f5831b[i4];
        }
    }

    @Override // Y0.d
    public final Map c() {
        switch (this.f5823d) {
            case 0:
                return (b) this.e;
            default:
                throw new UnsupportedOperationException("not a map");
        }
    }

    @Override // Y0.d
    public final int d() {
        switch (this.f5823d) {
            case 0:
                return ((b) this.e).f5856c;
            default:
                return ((c) this.e).f5832c;
        }
    }

    @Override // Y0.d
    public final int e(Object obj) {
        switch (this.f5823d) {
            case 0:
                return ((b) this.e).d(obj);
            default:
                c cVar = (c) this.e;
                return obj == null ? cVar.i() : cVar.h(obj.hashCode(), obj);
        }
    }

    @Override // Y0.d
    public final int f(Object obj) {
        switch (this.f5823d) {
            case 0:
                return ((b) this.e).f(obj);
            default:
                c cVar = (c) this.e;
                return obj == null ? cVar.i() : cVar.h(obj.hashCode(), obj);
        }
    }

    @Override // Y0.d
    public final void g(Object obj, Object obj2) {
        switch (this.f5823d) {
            case 0:
                ((b) this.e).put(obj, obj2);
                break;
            default:
                ((c) this.e).add(obj);
                break;
        }
    }

    @Override // Y0.d
    public final void h(int i4) {
        switch (this.f5823d) {
            case 0:
                ((b) this.e).h(i4);
                break;
            default:
                ((c) this.e).j(i4);
                break;
        }
    }

    @Override // Y0.d
    public final Object i(int i4, Object obj) {
        switch (this.f5823d) {
            case 0:
                int i5 = (i4 << 1) + 1;
                Object[] objArr = ((b) this.e).f5855b;
                Object obj2 = objArr[i5];
                objArr[i5] = obj;
                return obj2;
            default:
                throw new UnsupportedOperationException("not a map");
        }
    }
}
