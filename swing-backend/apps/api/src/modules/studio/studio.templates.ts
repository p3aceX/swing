import { SceneType } from '@swing/db'

export const DEFAULT_TEMPLATE_ID = 'classic-lower-third'

export interface OverlayTemplateDefinition {
  id: string
  name: string
  supportedSceneTypes: SceneType[]
  defaultData: Record<string, unknown>
  schema: Record<string, unknown>
}

export const TEMPLATES: Record<string, OverlayTemplateDefinition> = {
  [DEFAULT_TEMPLATE_ID]: {
    id: DEFAULT_TEMPLATE_ID,
    name: 'Classic Lower Third',
    supportedSceneTypes: [
      SceneType.PRE_MATCH,
      SceneType.LIVE_SCORE,
      SceneType.OVER_BREAK,
      SceneType.INNINGS_BREAK,
      SceneType.AD_BREAK,
      SceneType.POST_MATCH,
    ],
    defaultData: {
      teamAName: '',
      teamALogo: null,
      teamBName: '',
      teamBLogo: null,
      score: {
        runs: 0,
        wickets: 0,
        overs: 0,
      },
      target: null,
      tossWinner: null,
      tossChoice: null,
      lastOver: {
        balls: [],
      },
      overNumber: 0,
      inningsNumber: 1,
      result: null,
      adSlot: null,
    },
    schema: {
      type: 'object',
      properties: {
        teamAName: { type: 'string', title: 'Team A Name' },
        teamALogo: { type: 'string', title: 'Team A Logo URL' },
        teamBName: { type: 'string', title: 'Team B Name' },
        teamBLogo: { type: 'string', title: 'Team B Logo URL' },
        target: { type: 'number', title: 'Target' },
        tossWinner: { type: 'string', title: 'Toss Winner' },
        tossChoice: { type: 'string', title: 'Toss Choice' },
        overNumber: { type: 'number', title: 'Over Number' },
        inningsNumber: { type: 'number', title: 'Innings Number' },
        result: { type: 'string', title: 'Result' },
        score: {
          type: 'object',
          title: 'Score',
          properties: {
            runs: { type: 'number', title: 'Runs' },
            wickets: { type: 'number', title: 'Wickets' },
            overs: { type: 'number', title: 'Overs' },
          },
        },
        adSlot: {
          type: 'object',
          title: 'Ad Slot',
          properties: {
            type: { type: 'string', title: 'Type' },
            brandName: { type: 'string', title: 'Brand Name' },
            brandLogoUrl: { type: 'string', title: 'Brand Logo URL' },
            mediaUrl: { type: 'string', title: 'Media URL' },
            durationSeconds: { type: 'number', title: 'Duration Seconds' },
          },
        },
      },
    },
  },
}

export function getTemplate(templateId: string) {
  return TEMPLATES[templateId]
}

export function listTemplates() {
  return Object.values(TEMPLATES)
}
