package androidx.datastore.preferences.protobuf;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0195f extends C0196g {
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f2967f;

    public C0195f(byte[] bArr, int i4, int i5) {
        super(bArr);
        C0196g.g(i4, i4 + i5, bArr.length);
        this.e = i4;
        this.f2967f = i5;
    }

    @Override // androidx.datastore.preferences.protobuf.C0196g
    public final byte f(int i4) {
        int i5 = this.f2967f;
        if (((i5 - (i4 + 1)) | i4) >= 0) {
            return this.f2971b[this.e + i4];
        }
        if (i4 < 0) {
            throw new ArrayIndexOutOfBoundsException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "Index < 0: "));
        }
        throw new ArrayIndexOutOfBoundsException(B1.a.k("Index > length: ", i4, i5, ", "));
    }

    @Override // androidx.datastore.preferences.protobuf.C0196g
    public final void i(byte[] bArr, int i4) {
        System.arraycopy(this.f2971b, this.e, bArr, 0, i4);
    }

    @Override // androidx.datastore.preferences.protobuf.C0196g
    public final int j() {
        return this.e;
    }

    @Override // androidx.datastore.preferences.protobuf.C0196g
    public final byte k(int i4) {
        return this.f2971b[this.e + i4];
    }

    @Override // androidx.datastore.preferences.protobuf.C0196g
    public final int size() {
        return this.f2967f;
    }
}
