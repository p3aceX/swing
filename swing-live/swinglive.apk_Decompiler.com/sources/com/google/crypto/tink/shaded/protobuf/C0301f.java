package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0301f extends C0302g {
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f3784f;

    public C0301f(byte[] bArr, int i4, int i5) {
        super(bArr);
        AbstractC0303h.g(i4, i4 + i5, bArr.length);
        this.e = i4;
        this.f3784f = i5;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.C0302g, com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public final byte f(int i4) {
        int i5 = this.f3784f;
        if (((i5 - (i4 + 1)) | i4) >= 0) {
            return this.f3790d[this.e + i4];
        }
        if (i4 < 0) {
            throw new ArrayIndexOutOfBoundsException(S.d(i4, "Index < 0: "));
        }
        throw new ArrayIndexOutOfBoundsException(B1.a.k("Index > length: ", i4, i5, ", "));
    }

    @Override // com.google.crypto.tink.shaded.protobuf.C0302g, com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public final void i(byte[] bArr, int i4) {
        System.arraycopy(this.f3790d, this.e, bArr, 0, i4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.C0302g
    public final int k() {
        return this.e;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.C0302g
    public final byte l(int i4) {
        return this.f3790d[this.e + i4];
    }

    @Override // com.google.crypto.tink.shaded.protobuf.C0302g, com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public final int size() {
        return this.f3784f;
    }
}
