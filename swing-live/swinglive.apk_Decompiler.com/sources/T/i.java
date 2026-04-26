package t;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Typeface;
import android.graphics.fonts.Font;
import android.graphics.fonts.FontFamily;
import android.graphics.fonts.FontStyle;
import android.os.ParcelFileDescriptor;
import e1.AbstractC0367g;
import java.io.IOException;
import java.io.InputStream;
import x.C0710g;

/* JADX INFO: loaded from: classes.dex */
public final class i extends AbstractC0367g {
    public static Font c0(FontFamily fontFamily, int i4) {
        FontStyle fontStyle = new FontStyle((i4 & 1) != 0 ? 700 : 400, (i4 & 2) != 0 ? 1 : 0);
        Font font = fontFamily.getFont(0);
        int iD0 = d0(fontStyle, font.getStyle());
        for (int i5 = 1; i5 < fontFamily.getSize(); i5++) {
            Font font2 = fontFamily.getFont(i5);
            int iD02 = d0(fontStyle, font2.getStyle());
            if (iD02 < iD0) {
                font = font2;
                iD0 = iD02;
            }
        }
        return font;
    }

    public static int d0(FontStyle fontStyle, FontStyle fontStyle2) {
        return (Math.abs(fontStyle.getWeight() - fontStyle2.getWeight()) / 100) + (fontStyle.getSlant() == fontStyle2.getSlant() ? 0 : 2);
    }

    @Override // e1.AbstractC0367g
    public final Typeface i(Context context, s.f fVar, Resources resources, int i4) {
        try {
            FontFamily.Builder builder = null;
            for (s.g gVar : fVar.f6443a) {
                try {
                    Font fontBuild = new Font.Builder(resources, gVar.f6448f).setWeight(gVar.f6445b).setSlant(gVar.f6446c ? 1 : 0).setTtcIndex(gVar.e).setFontVariationSettings(gVar.f6447d).build();
                    if (builder == null) {
                        builder = new FontFamily.Builder(fontBuild);
                    } else {
                        builder.addFont(fontBuild);
                    }
                } catch (IOException unused) {
                }
            }
            if (builder == null) {
                return null;
            }
            FontFamily fontFamilyBuild = builder.build();
            return new Typeface.CustomFallbackBuilder(fontFamilyBuild).setStyle(c0(fontFamilyBuild, i4).getStyle()).build();
        } catch (Exception unused2) {
            return null;
        }
    }

    @Override // e1.AbstractC0367g
    public final Typeface j(Context context, C0710g[] c0710gArr, int i4) {
        ParcelFileDescriptor parcelFileDescriptorOpenFileDescriptor;
        ContentResolver contentResolver = context.getContentResolver();
        try {
            FontFamily.Builder builder = null;
            for (C0710g c0710g : c0710gArr) {
                try {
                    parcelFileDescriptorOpenFileDescriptor = contentResolver.openFileDescriptor(c0710g.f6743a, "r", null);
                } catch (IOException unused) {
                }
                if (parcelFileDescriptorOpenFileDescriptor == null) {
                    if (parcelFileDescriptorOpenFileDescriptor != null) {
                    }
                } else {
                    try {
                        Font fontBuild = new Font.Builder(parcelFileDescriptorOpenFileDescriptor).setWeight(c0710g.f6745c).setSlant(c0710g.f6746d ? 1 : 0).setTtcIndex(c0710g.f6744b).build();
                        if (builder == null) {
                            builder = new FontFamily.Builder(fontBuild);
                        } else {
                            builder.addFont(fontBuild);
                        }
                    } catch (Throwable th) {
                        try {
                            parcelFileDescriptorOpenFileDescriptor.close();
                        } catch (Throwable th2) {
                            th.addSuppressed(th2);
                        }
                        throw th;
                    }
                }
                parcelFileDescriptorOpenFileDescriptor.close();
            }
            if (builder != null) {
                FontFamily fontFamilyBuild = builder.build();
                return new Typeface.CustomFallbackBuilder(fontFamilyBuild).setStyle(c0(fontFamilyBuild, i4).getStyle()).build();
            }
        } catch (Exception unused2) {
        }
        return null;
    }

    @Override // e1.AbstractC0367g
    public final Typeface k(Context context, InputStream inputStream) {
        throw new RuntimeException("Do not use this function in API 29 or later.");
    }

    @Override // e1.AbstractC0367g
    public final Typeface l(Context context, Resources resources, int i4, String str, int i5) {
        try {
            Font fontBuild = new Font.Builder(resources, i4).build();
            return new Typeface.CustomFallbackBuilder(new FontFamily.Builder(fontBuild).build()).setStyle(fontBuild.getStyle()).build();
        } catch (Exception unused) {
            return null;
        }
    }

    @Override // e1.AbstractC0367g
    public final C0710g r(C0710g[] c0710gArr, int i4) {
        throw new RuntimeException("Do not use this function in API 29 or later.");
    }
}
